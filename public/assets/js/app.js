/* ═══════════════════════════════════════════════════════
   DONARE — main.js
   Data is loaded from the PHP/MySQL backend (see API constant below).
═══════════════════════════════════════════════════════ */

const API = "/donare-v/api";

/* ── STATE ── */
let campaigns = []; // populated by loadCampaigns()
let myDonations = []; // populated in renderHistory()
let currentUser = null;
let csrfToken = null;
let sessionMonitorInterval = null;

/* ── PASSWORD VALIDATION ── */
function validatePassword(password) {
  const errors = [];
  if (password.length < 6) {
    errors.push("Password  must be at least 6 characters.");
  }
  return { valid: errors.length === 0, errors };
}

/* ── SESSION MANAGEMENT ── */
async function checkSession() {
  // For now, restore from localStorage (server-side sessions can be added later)
  restoreSession();
  return !!currentUser;
}

function startSessionMonitor() {
  // Monitor session validity periodically
  stopSessionMonitor();
  sessionMonitorInterval = setInterval(async () => {
    // Could add server-side session check here
    // For now, just ensure localStorage is synced
    if (!localStorage.getItem("donareUser") && currentUser) {
      currentUser = null;
      showToast("Session ended. Please log in again.");
      switchPage("home");
    }
  }, 60000); // Check every minute
}

function stopSessionMonitor() {
  if (sessionMonitorInterval) {
    clearInterval(sessionMonitorInterval);
    sessionMonitorInterval = null;
  }
}

/* ── SESSION MANAGEMENT (localStorage) ── */

function saveSession() {
  if (currentUser) {
    localStorage.setItem("donareUser", JSON.stringify(currentUser));
  } else {
    localStorage.removeItem("donareUser");
  }
  updateNav();
}

function restoreSession() {
  const stored = localStorage.getItem("donareUser");
  if (stored) {
    try {
      currentUser = JSON.parse(stored);
    } catch (e) {
      currentUser = null;
    }
  }
}

let currentPage = "home";
let filterCategory = "All";
let activeCampaignId = null;
let aiGeneratedDesc = "";

/* ─────────────────────────────────────────────────────
   NGO HISTORY — now stored in database via ngo_history table
───────────────────────────────────────────────────── */

/* ─────────────────────────────────────────────────────
   SECURITY — XSS prevention
───────────────────────────────────────────────────── */
function escapeHTML(str) {
  if (str === null || str === undefined) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

/* ─────────────────────────────────────────────────────
   HELPERS
───────────────────────────────────────────────────── */
const pct = (r, g) => Math.min(100, Math.round((r / g) * 100));

const catBadge = (cat) =>
  `<span class="card-cat cat-${escapeHTML(cat)}">${escapeHTML(cat)}</span>`;

const statusBadge = (s) =>
  `<span class="badge ${s === "Completed" ? "badge-done" : "badge-pending"}">${escapeHTML(s)}</span>`;

const progressBar = (r, g, h = "6px") =>
  `<div class="progress-bar" style="height:${h}"><div class="progress-fill" style="width:${pct(r, g)}%"></div></div>`;

/* Category emojis removed - campaign cards show blank if no image */

/* ── Loading placeholder ── */
function loadingHTML(colspan = 1) {
  return `<tr><td colspan="${colspan}" style="text-align:center;padding:40px;color:var(--dim)">Loading…</td></tr>`;
}
function gridLoadingHTML() {
  return `<div style="grid-column:1/-1;text-align:center;padding:60px;color:var(--dim)">Loading campaigns…</div>`;
}

/* ─────────────────────────────────────────────────────
   API FETCH WRAPPER
   Centralised error handling for all fetch calls.
   Includes credentials for session cookies.
───────────────────────────────────────────────────── */
async function apiFetch(url, options = {}) {
  try {
    // Always include credentials for session cookies
    options.credentials = 'include';
    
    const res = await fetch(url, options);
    
    // Check if response is JSON
    const contentType = res.headers.get('content-type');
    if (!contentType || !contentType.includes('application/json')) {
      console.error('Non-JSON response from:', url, 'Content-Type:', contentType);
      const text = await res.text();
      console.error('Response text:', text.substring(0, 500));
      return {
        ok: false,
        data: { error: 'Server returned invalid response. Please check server logs.' },
      };
    }
    
    const data = await res.json();
    
    // Handle session expiration
    if (res.status === 401 && data.code === 'SESSION_EXPIRED') {
      currentUser = null;
      stopSessionMonitor();
      showToast("Your session has expired. Please log in again.");
      switchPage("login");
      return { ok: false, data };
    }
    
    return { ok: res.ok, status: res.status, data };
  } catch (err) {
    console.error("API error:", url, err);
    console.error("Error details:", err.message, err.stack);
    return {
      ok: false,
      data: { error: "Network error. Please check: 1) Is WAMP running? 2) Check browser console for details." },
    };
  }
}

/* ─────────────────────────────────────────────────────
   CAMPAIGNS — load from DB and normalise field names
   The DB returns: image_url, description, days_left, ngo
   The render functions expect: image, desc, daysLeft, ngo
───────────────────────────────────────────────────── */
async function loadCampaigns() {
  const { ok, data } = await apiFetch(`${API}/campaigns.php`);
  if (!ok) {
    showToast("Could not load campaigns.");
    return;
  }
  // Normalise DB column names → JS property names
  campaigns = data.map((c) => ({
    id: parseInt(c.id),
    title: c.title,
    ngo: c.ngo,
    category: c.category,
    goal: parseFloat(c.goal),
    raised: parseFloat(c.raised),
    donors: parseInt(c.donors),
    daysLeft: parseInt(c.days_left),
    image: c.image_url || "",
    desc: c.description || "",
    maxDonation: c.max_donation !== null ? parseFloat(c.max_donation) : null,
  }));
}

/* ─────────────────────────────────────────────────────
   NAV UPDATE
───────────────────────────────────────────────────── */
function updateNav() {
  const role = currentUser?.role;
  const loggedIn = !!currentUser;

  document.getElementById("publicNavLinks").style.display =
    !loggedIn || role === "user" ? "flex" : "none";
  document.getElementById("adminNavLinks").style.display =
    role === "admin" ? "flex" : "none";
  document.getElementById("trusteeNavLinks").style.display =
    role === "trustee" ? "flex" : "none";
  document.getElementById("myDonationsTab").style.display =
    loggedIn && role === "user" ? "" : "none";

  document.getElementById("navAuth").style.display = loggedIn ? "none" : "flex";
  document.getElementById("navUserChip").style.display = loggedIn
    ? "flex"
    : "none";
  if (loggedIn)
    document.getElementById("navUserName").textContent = currentUser.name;

  document.querySelectorAll(".nav-link").forEach((b) => {
    const oc = b.getAttribute("onclick") || "";
    b.classList.toggle("active", oc.includes(`'${currentPage}'`));
  });
}

function toggleMobileMenu() {
  const menu = document.getElementById("navMenu");
  if (menu) {
    menu.classList.toggle("open");
  }
}

/* ─────────────────────────────────────────────────────
   PAGE ROUTER
───────────────────────────────────────────────────── */
async function switchPage(page) {
  // Access guards
  if (page === "history" && !currentUser) {
    showToast("Please log in to view your donations.");
    switchPage("login");
    return;
  }
  if (
    ["admin-campaigns", "admin-donations", "admin-support"].includes(page) &&
    currentUser?.role !== "admin"
  )
    return;
  if (page === "trustee" && currentUser?.role !== "trustee") return;

  // Close mobile menu on navigate
  const menu = document.getElementById("navMenu");
  if (menu) {
    menu.classList.remove("open");
  }

  currentPage = page;
  document
    .querySelectorAll(".page")
    .forEach((p) => p.classList.remove("active"));
  const el = document.getElementById("page-" + page);
  if (el) el.classList.add("active");

  updateNav();

  // Render hooks — all async now
  if (page === "home") await renderHomeGrid();
  if (page === "campaigns") await renderCampaigns();
  if (page === "history") await renderHistory();
  if (page === "admin-campaigns") await renderAdminCampaigns();
  if (page === "admin-donations") await renderAdminDonations();
  if (page === "admin-support") await renderAdminSupport();
  if (page === "trustee") await renderTrustee();

  window.scrollTo(0, 0);
}

/* ─────────────────────────────────────────────────────
   HOME
───────────────────────────────────────────────────── */
async function renderHomeGrid() {
  document.getElementById("homeGrid").innerHTML = gridLoadingHTML();
  await loadCampaigns();
  document.getElementById("homeGrid").innerHTML = campaigns
    .slice(0, 3)
    .map(cardHTML)
    .join("");
}

/* ─────────────────────────────────────────────────────
   CAMPAIGNS
───────────────────────────────────────────────────── */
async function renderCampaigns() {
  document.getElementById("campaignGrid").innerHTML = gridLoadingHTML();
  await loadCampaigns();

  const cats = ["All", ...new Set(campaigns.map((c) => c.category))];
  document.getElementById("filterPills").innerHTML = cats
    .map(
      (c) =>
        `<button class="pill ${filterCategory === c ? "active" : ""}" onclick="setFilter('${escapeHTML(c)}')">${escapeHTML(c)}</button>`,
    )
    .join("");

  const list =
    filterCategory === "All"
      ? campaigns
      : campaigns.filter((c) => c.category === filterCategory);
  document.getElementById("campaignGrid").innerHTML = list
    .map(cardHTML)
    .join("");
}

/* ── Campaign card HTML ── */
function cardHTML(c) {
  // Handle both absolute URLs (http/https) and relative URLs (uploads/)
  const hasImage = c.image && (c.image.startsWith("http") || c.image.startsWith("uploads/") || c.image.startsWith("/"));
  const imgHTML = hasImage
      ? `<img src="${escapeHTML(c.image)}" alt="${escapeHTML(c.title)}" loading="lazy"/>`
      : `<div style="display:flex;align-items:center;justify-content:center;height:100%;background:var(--bg3)"></div>`;
  
  // Check if campaign is fully funded
  const goalReached = c.goal_reached || c.remaining_to_goal <= 0 || c.raised >= c.goal;
  const donateButtonHTML = goalReached
    ? `<button class="btn-donate" style="background:var(--green);cursor:default" disabled>Fully Funded ✓</button>`
    : `<button class="btn-donate" onclick="handleDonateClick(${c.id})">Donate</button>`;
  
  // Show remaining amount if not fully funded
  const remainingInfo = !goalReached && c.remaining_to_goal 
    ? `<div class="days-left" style="font-size:11px;color:var(--green)">💰 ₹${c.remaining_to_goal.toLocaleString()} needed</div>`
    : '';
  
  return `
  <div class="card" id="card-${c.id}">
    <div class="card-img">
      ${imgHTML}
      ${catBadge(c.category)}
      ${goalReached ? '<div class="goal-reached-badge">🎉 Goal Reached!</div>' : ''}
    </div>
    <div class="card-body">
      <div class="card-header">
        <div class="card-title">${escapeHTML(c.title)}</div>
        <div class="card-ngo">🏢 ${escapeHTML(c.ngo)}</div>
      </div>
      <div class="card-desc">${escapeHTML(c.desc)}</div>
      <div class="card-progress-wrapper">
        ${progressBar(c.raised, c.goal)}
        <div class="progress-info">
          <span>₹ ${c.raised.toLocaleString()} raised of ₹ ${c.goal.toLocaleString()}</span>
          <span class="progress-pct">${Math.min(100, pct(c.raised, c.goal))}%</span>
        </div>
      </div>
      <div class="card-footer">
        <div class="stats-left" style="display:flex;flex-direction:column;gap:4px">
          <div class="days-left">⏳ <b>${c.daysLeft} days left</b></div>
          <div class="days-left" style="font-size:11px">👥 ${c.donors} donors</div>
          ${remainingInfo}
        </div>
        <div style="display:flex;gap:8px;align-items:center">
          <button class="btn-view-more" onclick="openNgoHistory(${c.id})">Details</button>
          ${donateButtonHTML}
        </div>
      </div>
    </div>
  </div>`;
}

function setFilter(cat) {
  filterCategory = cat;
  renderCampaigns();
}

function handleDonateClick(id) {
  if (!currentUser) {
    showToast("Please log in or sign up to donate.");
    switchPage("login");
    return;
  }
  openDonateModal(id);
}

/* ─────────────────────────────────────────────────────
   MY DONATIONS (user history)
───────────────────────────────────────────────────── */
async function renderHistory() {
  document.getElementById("historyBody").innerHTML = loadingHTML(6);

  const { ok, data } = await apiFetch(
    `${API}/my_donations.php?email=${encodeURIComponent(currentUser.email)}`,
  );
  if (!ok) {
    document.getElementById("historyBody").innerHTML =
      `<tr><td colspan="6" style="text-align:center;padding:40px;color:var(--red)">Could not load donations.</td></tr>`;
    return;
  }

  myDonations = data;
  document.getElementById("historyBody").innerHTML = myDonations.length
    ? myDonations
        .map(
          (d) => `
      <tr>
        <td style="color:var(--green);font-weight:600;font-size:12px">${escapeHTML(d.receipt_id || d.id || "—")}</td>
        <td>${escapeHTML(d.campaign_title || d.campaign || "—")}</td>
        <td style="color:var(--gold);font-weight:700">₹ ${parseFloat(d.amount).toLocaleString()}</td>
        <td><span class="pay-badge">${escapeHTML(d.payment_method || "—")}</span></td>
        <td style="color:var(--dim)">${escapeHTML(d.donated_at || d.date || "—")}</td>
        <td>${statusBadge(d.status)}</td>
      </tr>`,
        )
        .join("")
    : `<tr><td colspan="6" style="text-align:center;padding:40px;color:var(--dim)">
        No donations yet. <span style="color:var(--gold);cursor:pointer" onclick="switchPage('campaigns')">Browse campaigns →</span>
      </td></tr>`;
}

/* ─────────────────────────────────────────────────────
   ADMIN — CAMPAIGNS
───────────────────────────────────────────────────── */
async function renderAdminCampaigns() {
  document.getElementById("adminCampaignBody").innerHTML = loadingHTML(7);

  const { ok, data: allCampaigns } = await apiFetch(
    `${API}/admin_campaigns.php`,
  );
  if (!ok) {
    showToast("Could not load campaigns.");
    return;
  }
  campaigns = allCampaigns.map((c) => ({
    id: parseInt(c.id),
    title: c.title,
    ngo: c.ngo,
    category: c.category,
    goal: parseFloat(c.goal),
    raised: parseFloat(c.raised),
    donors: parseInt(c.donors),
    daysLeft: parseInt(c.days_left),
    image: c.image_url || "",
    desc: c.description || "",
    maxDonation: c.max_donation !== null ? parseFloat(c.max_donation) : null,
    isActive: c.is_active == 1,
  }));

  // KPI cards
  document.getElementById("kpiCampaigns").textContent = campaigns.length;
  document.getElementById("kpiRaised").textContent =
    "₹ " +
    (campaigns.reduce((a, c) => a + c.raised, 0) / 1000).toFixed(1) +
    "K";
  document.getElementById("kpiDonors").textContent = campaigns
    .reduce((a, c) => a + c.donors, 0)
    .toLocaleString();

  // Table rows with max donation column
  document.getElementById("adminCampaignBody").innerHTML = campaigns
    .map(
      (c) => `
    <tr style="${!c.isActive ? 'opacity:0.5' : ''}">
      <td style="font-weight:600">${escapeHTML(c.title)}${!c.isActive ? ' <span style="color:var(--red);font-size:10px">(Inactive)</span>' : ''}</td>
      <td style="color:var(--dim);font-size:12px">${escapeHTML(c.ngo)}</td>
      <td>${catBadge(c.category)}</td>
      <td style="color:var(--gold);font-weight:700">₹ ${c.raised.toLocaleString()}</td>
      <td style="min-width:120px">
        ${progressBar(c.raised, c.goal)}
        <div style="font-size:11px;color:var(--dim);margin-top:3px">${pct(c.raised, c.goal)}% of ₹ ${(c.goal / 1000).toFixed(0)}K</div>
      </td>
      <td style="font-size:12px;color:var(--dim)">${c.maxDonation !== null ? '₹' + c.maxDonation.toLocaleString() : '—'}</td>
      <td>
        <button class="btn-edit" onclick="openEditModal(${c.id})">Edit</button>
        <button class="btn-del"  onclick="deleteCampaign(${c.id})">Delete</button>
      </td>
    </tr>`,
    )
    .join("");
}

/* ─────────────────────────────────────────────────────
   ADMIN — DONATIONS
───────────────────────────────────────────────────── */
async function renderAdminDonations() {
  document.getElementById("adminDonationBody").innerHTML = loadingHTML(8);

  const { ok, data } = await apiFetch(`${API}/admin_donations.php`);
  if (!ok) {
    document.getElementById("adminDonationBody").innerHTML =
      `<tr><td colspan="8" style="text-align:center;padding:40px;color:var(--red)">Could not load donations.</td></tr>`;
    return;
  }

  document.getElementById("donationCount").textContent = data.length + " records";
  document.getElementById("adminDonationBody").innerHTML = data.length
    ? data.map((d) => {
        // Handle donor_name - don't treat 0 or empty string as falsy
        const donorName = (d.donor_name !== null && d.donor_name !== undefined && d.donor_name !== '') 
          ? d.donor_name 
          : (d.donor || "—");
        
        return `
    <tr>
      <td style="color:var(--green);font-weight:600;font-size:11px">${escapeHTML(d.receipt_id || d.id)}</td>
      <td>
        <div style="font-weight:600">${escapeHTML(donorName)}</div>
        <div style="font-size:11px;color:var(--dim)">${escapeHTML(d.donor_email || d.email || "—")}</div>
      </td>
      <td>${escapeHTML(d.campaign_title || d.campaign || "—")}</td>
      <td style="color:var(--gold);font-weight:700">₹ ${parseFloat(d.amount).toLocaleString()}</td>
      <td><span class="pay-badge">${escapeHTML(d.payment_method || "—")}</span></td>
      <td style="color:var(--dim);font-size:12px">${escapeHTML(d.donated_at || d.date || "—")}</td>
      <td>${statusBadge(d.status)}</td>
      <td><button class="btn-del" onclick="deleteDonation('${escapeHTML(d.receipt_id || d.id)}')">Delete</button></td>
    </tr>`;
      }).join("")
    : `<tr><td colspan="8" style="text-align:center;padding:40px;color:var(--dim)">No donations yet.</td></tr>`;

  // Auto-refresh every 30 seconds while on this page
  clearTimeout(window._donationRefreshTimer);
  window._donationRefreshTimer = setTimeout(() => {
    if (currentPage === "admin-donations") renderAdminDonations();
  }, 30000);
}

async function deleteDonation(receiptId) {
  if (
    !confirm(
      "Delete this donation record? This will also reverse the campaign total.",
    )
  )
    return;
  const { ok, data } = await apiFetch(`${API}/admin_donations.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ _method: "DELETE", receipt_id: receiptId }),
  });
  if (!ok) {
    showToast(data.error || "Could not delete donation.");
    return;
  }
  await renderAdminDonations();
  showToast("Donation record deleted.");
}
/* ─────────────────────────────────────────────────────
   TRUSTEE DASHBOARD
───────────────────────────────────────────────────── */
async function renderTrustee() {
  document.getElementById("trusteeCampaigns").innerHTML =
    '<div style="padding:20px;color:var(--dim)">Loading…</div>';
  document.getElementById("trusteeDonationBody").innerHTML = loadingHTML(4);

  const ngo = encodeURIComponent(currentUser.ngo || "");
  const { ok, data } = await apiFetch(`${API}/trustee.php?ngo=${ngo}`);
  if (!ok) {
    showToast("Could not load trustee data.");
    return;
  }

  // KPI cards — live from DB
  const totalRaised = data.campaigns.reduce(
    (a, c) => a + parseFloat(c.raised),
    0,
  );
  const totalDonors = data.campaigns.reduce(
    (a, c) => a + parseInt(c.donors),
    0,
  );
  document.getElementById("trusteeKpiCampaigns").textContent =
    data.campaigns.length;
  document.getElementById("trusteeKpiRaised").textContent =
    "₹ " + totalRaised.toLocaleString();
  document.getElementById("trusteeKpiDonors").textContent =
    totalDonors.toLocaleString();

  // Campaign rows with Edit/Delete buttons
  document.getElementById("trusteeCampaigns").innerHTML = data.campaigns.length
    ? data.campaigns
        .map(
          (c) => `
      <div class="trustee-row">
        <div class="trustee-info">
          <div class="trustee-name">${escapeHTML(c.title)}</div>
          <div class="trustee-raised">₹ ${parseFloat(c.raised).toLocaleString()} raised of ₹ ${parseFloat(c.goal).toLocaleString()}</div>
          <div style="margin-top:6px">${progressBar(c.raised, c.goal, "5px")}</div>
        </div>
        <div style="text-align:right;font-size:13px;color:var(--dim)">
          <div style="color:var(--gold);font-weight:700">${pct(c.raised, c.goal)}%</div>
          <div style="margin-bottom:8px">${c.donors} donors</div>
          <button class="btn-edit" onclick="openEditModal(${c.id})">Edit</button>
          <button class="btn-del"  onclick="deleteCampaign(${c.id})">Delete</button>
        </div>
      </div>`,
        )
        .join("")
    : '<div style="padding:20px;color:var(--dim)">No campaigns found for your NGO.</div>';

  // History records from DB
  document.getElementById("trusteeHistory").innerHTML = data.history.length
    ? data.history
        .map(
          (h) => `
        <div class="history-record">
          <div class="history-record-title">${escapeHTML(h.title)} (${escapeHTML(h.year)})</div>
          <div class="history-record-grid">
            <div class="history-stat"><div class="history-stat-val">₹ ${parseFloat(h.raised).toLocaleString()}</div><div class="history-stat-label">Total Raised</div></div>
            <div class="history-stat"><div class="history-stat-val">₹ ${parseFloat(h.distributed).toLocaleString()}</div><div class="history-stat-label">Funds Distributed</div></div>
            <div class="history-stat"><div class="history-stat-val">${escapeHTML(h.beneficiaries)}</div><div class="history-stat-label">Beneficiaries</div></div>
            <div class="history-stat"><div class="history-stat-val" style="font-size:13px">${escapeHTML(h.period)}</div><div class="history-stat-label">Campaign Period</div></div>
          </div>
          <div class="history-note">📝 ${escapeHTML(h.note)}</div>
        </div>`,
        )
        .join("")
    : '<div style="padding:20px;color:var(--dim)">No history records yet.</div>';

  // Donation rows
  document.getElementById("trusteeDonationBody").innerHTML = data.donations
    .length
    ? data.donations
        .map(
          (d) => `
      <tr>
        <td style="font-weight:600">${escapeHTML(d.donor)}</td>
        <td style="color:var(--gold);font-weight:700">₹ ${parseFloat(d.amount).toLocaleString()}</td>
        <td style="color:var(--dim)">${escapeHTML(d.date)}</td>
        <td>${statusBadge(d.status)}</td>
      </tr>`,
        )
        .join("")
    : `<tr><td colspan="4" style="text-align:center;padding:40px;color:var(--dim)">No donations yet.</td></tr>`;
}

/* ─────────────────────────────────────────────────────
   LOGIN
───────────────────────────────────────────────────── */
async function doLogin() {
  const email = document
    .getElementById("loginEmail")
    .value.trim()
    .toLowerCase();
  const pass = document.getElementById("loginPassword").value;
  const err = document.getElementById("loginError");
  err.classList.remove("show");

  if (!email || !pass) {
    err.textContent = "Please enter your email and password.";
    err.classList.add("show");
    return;
  }

  const { ok, status, data } = await apiFetch(`${API}/login.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password: pass }),
  });

  if (!ok) {
    let errorMsg = data.error || "Invalid email or password.";
    
    // Show rate limit info if applicable
    if (status === 429) {
      const mins = Math.ceil((data.lockout_seconds || 900) / 60);
      errorMsg = `Too many failed attempts. Please try again in ${mins} minute(s).`;
    } else if (data.attempts_remaining !== undefined && data.attempts_remaining <= 2) {
      errorMsg += ` (${data.attempts_remaining} attempts remaining)`;
    }
    
    err.textContent = errorMsg;
    err.classList.add("show");
    return;
  }

  // Store CSRF token from server
  if (data.csrf_token) {
    csrfToken = data.csrf_token;
  }

  currentUser = {
    id: data.id,
    email: data.email,
    name: data.name,
    role: data.role,
    ngo: data.ngo_name || null,
    emailVerified: data.email_verified,
  };
  
  // Start session monitoring
  startSessionMonitor();
  saveSession();

  clearLoginFields();

  if (data.role === "admin") {
    switchPage("admin-campaigns");
  } else if (data.role === "trustee") {
    switchPage("trustee");
  } else {
    switchPage("home");
  }

  // Show verification warning if email not verified
  if (!data.email_verified) {
    showToast("Welcome back! Please verify your email address.");
  } else {
    showToast("Welcome back, " + data.name + "!");
  }
}

function clearLoginFields() {
  document.getElementById("loginEmail").value = "";
  document.getElementById("loginPassword").value = "";
}

/* ─────────────────────────────────────────────────────
   SIGNUP
───────────────────────────────────────────────────── */
async function doSignup() {
  const name = document.getElementById("signupName").value.trim();
  const email = document.getElementById("signupEmail").value.trim();
  const pass = document.getElementById("signupPassword").value;
  const confirm = document.getElementById("signupConfirm").value;
  const err = document.getElementById("signupError");
  
  // Clear all previous errors
  err.classList.remove("show");
  clearFieldError('signupName');
  clearFieldError('signupEmail');
  clearFieldError('signupPassword');
  clearFieldError('signupConfirm');

  let hasError = false;

  // Validate name
  if (!name) {
    showFieldError('signupName', 'Full name is required');
    hasError = true;
  } else if (name.length < 2) {
    showFieldError('signupName', 'Name must be at least 2 characters');
    hasError = true;
  }

  // Validate email
  if (!email) {
    showFieldError('signupEmail', 'Email address is required');
    hasError = true;
  } else if (!isValidEmail(email)) {
    showFieldError('signupEmail', 'Please enter a valid email address');
    hasError = true;
  }

  // Validate password
  if (!pass) {
    showFieldError('signupPassword', 'Password is required');
    hasError = true;
  } else {
    const passwordCheck = validatePassword(pass);
    if (!passwordCheck.valid) {
      showFieldError('signupPassword', passwordCheck.errors[0]);
      hasError = true;
    }
  }

  // Validate password confirmation
  if (!confirm) {
    showFieldError('signupConfirm', 'Please confirm your password');
    hasError = true;
  } else if (pass !== confirm) {
    showFieldError('signupConfirm', 'Passwords do not match');
    hasError = true;
  }

  if (hasError) {
    err.textContent = "Please fix the errors above to continue.";
    err.classList.add("show");
    return;
  }

  const { ok, data } = await apiFetch(`${API}/signup.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email, password: pass, website: "" }), // website is honeypot field (should be empty)
  });

  if (!ok) {
    // Show all password errors if returned by server
    const errorMsg = data.errors ? data.errors.join(' ') : (data.error || "Signup failed. Please try again.");
    err.textContent = errorMsg;
    err.classList.add("show");
    return;
  }

  // Store CSRF token from server
  if (data.csrf_token) {
    csrfToken = data.csrf_token;
  }

  currentUser = { id: data.id, email, name, role: "user", ngo: null, emailVerified: false };
  
  // Start session monitoring
  startSessionMonitor();
  saveSession();
  
  ["signupName", "signupEmail", "signupPassword", "signupConfirm"].forEach(
    (id) => (document.getElementById(id).value = ""),
  );
  
  // Clear password strength indicator
  const strengthIndicator = document.getElementById('signupPasswordStrength');
  if (strengthIndicator) {
    strengthIndicator.className = 'password-strength';
    strengthIndicator.textContent = '';
  }
  
  switchPage("home");
  showToast("Welcome to Donare, " + name + "! Please check your email to verify your account. 🎉");
}

/**
 * Show field-specific error message
 */
function showFieldError(fieldId, message) {
  const errorDiv = document.getElementById(fieldId + 'Error');
  if (errorDiv) {
    errorDiv.textContent = message;
    errorDiv.classList.add('show');
  }
}

/**
 * Clear field-specific error message
 */
function clearFieldError(fieldId) {
  const errorDiv = document.getElementById(fieldId + 'Error');
  if (errorDiv) {
    errorDiv.classList.remove('show');
    errorDiv.textContent = '';
  }
}

/**
 * Validate email format
 */
function isValidEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Toggle password visibility
 */
function togglePasswordVisibility(inputId, button) {
  const input = document.getElementById(inputId);
  const eyeIcon = button.querySelector('.eye-icon');
  
  if (input.type === 'password') {
    input.type = 'text';
    eyeIcon.textContent = '🙈'; // Eye closed icon
  } else {
    input.type = 'password';
    eyeIcon.textContent = '👁️'; // Eye open icon
  }
}

/**
 * Real-time password strength indicator
 */
function updatePasswordStrength(password) {
  const strengthDiv = document.getElementById('signupPasswordStrength');
  if (!strengthDiv) return;

  if (!password) {
    strengthDiv.classList.remove('show');
    return;
  }

  const check = validatePassword(password);
  strengthDiv.classList.add('show');
  
  // Determine strength level
  let strength = 'weak';
  let message = '';
  
  if (check.valid) {
    // Check additional criteria for strong password
    const hasUpper = /[A-Z]/.test(password);
    const hasLower = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    const hasSpecial = /[!@#$%^&*(),.?":{}|<>]/.test(password);
    const criteriaCount = [hasUpper, hasLower, hasNumber, hasSpecial].filter(Boolean).length;
    
    if (password.length >= 12 && criteriaCount >= 3) {
      strength = 'strong';
      message = '✓ Strong password';
    } else if (password.length >= 8 && criteriaCount >= 2) {
      strength = 'medium';
      message = '○ Medium strength - consider adding more variety';
    } else {
      strength = 'weak';
      message = '△ Weak password - add uppercase, numbers, or symbols';
    }
  } else {
    strength = 'weak';
    message = check.errors[0];
  }
  
  strengthDiv.className = 'password-strength show ' + strength;
  strengthDiv.textContent = message;
}

// Add event listeners when page loads
document.addEventListener('DOMContentLoaded', function() {
  const signupPassword = document.getElementById('signupPassword');
  if (signupPassword) {
    signupPassword.addEventListener('input', function() {
      updatePasswordStrength(this.value);
    });
  }
});

/* ─────────────────────────────────────────────────────
   LOGOUT
───────────────────────────────────────────────────── */
async function logout() {
  // Call server to destroy session
  try {
    await apiFetch(`${API}/logout.php`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    // Continue with local logout even if server call fails
    console.error("Logout API error:", err);
  }
  
  currentUser = null;
  csrfToken = null;
  stopSessionMonitor();
  saveSession();
  myDonations = [];
  filterCategory = "All";
  switchPage("home");
  showToast("You have been logged out.");
}

/* ─────────────────────────────────────────────────────
   DONATE MODAL
───────────────────────────────────────────────────── */
/* ─────────────────────────────────────────────────────
   DONATE — MULTI-STEP MODAL
───────────────────────────────────────────────────── */
let donateStep = 1;

function openDonateModal(id) {
  activeCampaignId = id;
  const c = campaigns.find((x) => x.id === id);
  
  // Check if campaign goal is already reached
  if (c.goal_reached || c.remaining_to_goal <= 0) {
    showToast("This campaign has reached its funding goal. Thank you for your interest!");
    return;
  }
  
  document.getElementById("donateEmoji").textContent = "💝";
  document.getElementById("donateTitle").textContent = "Donate to " + c.title;
  
  // Show remaining amount and transaction limit
  const remaining = c.remaining_to_goal || (c.goal - c.raised);
  const maxAllowed = c.max_allowed_donation || Math.min(remaining, 10000);
  const transactionLimit = c.transaction_limit || 10000;
  
  let subText = c.ngo + " · " + c.category;
  subText += ` · ₹${remaining.toLocaleString()} remaining to goal`;
  if (remaining > transactionLimit) {
    subText += ` · Max ₹${transactionLimit.toLocaleString()} per transaction`;
  }
  document.getElementById("donateSub").textContent = subText;

  // Pre-fill known user details
  document.getElementById("donorName").value    = currentUser?.name  || "";
  document.getElementById("donorEmail").value   = currentUser?.email || "";
  document.getElementById("donorPhone").value   = "";
  document.getElementById("donorAddress").value = "";

  // Reset amount + method
  document.getElementById("donateAmount").value  = "";
  document.getElementById("paymentMethod").value = "";
  document.querySelectorAll(".amt-btn").forEach((b) => b.classList.remove("active"));
  
  // Set max attribute on amount input based on smart donation cap
  const amountInput = document.getElementById("donateAmount");
  amountInput.max = maxAllowed;
  amountInput.placeholder = `Max ₹${maxAllowed.toLocaleString()}`;

  // Reset payment detail fields
  ["bankName","bankAccountName","bankAccountNumber","bankIfsc","bankRemarks"].forEach((fid) => {
    const el = document.getElementById(fid); if (el) el.value = "";
  });
  ["cardName","cardNumber","cardExpiry","cardCvv"].forEach((fid) => {
    const el = document.getElementById(fid); if (el) el.value = "";
  });
  const ct = document.getElementById("cardType");
  if (ct) ct.value = "Visa";

  gotoStep(1);
  openModal("donateModal");
}

function gotoStep(n) {
  donateStep = n;
  ["donateStep1","donateStep2","donateStep3Bank","donateStep3Card"].forEach((sid) => {
    const el = document.getElementById(sid);
    if (el) el.style.display = "none";
  });
  if (n === 1) document.getElementById("donateStep1").style.display = "block";
  if (n === 2) document.getElementById("donateStep2").style.display = "block";
  if (n === 3) {
    const method = document.getElementById("paymentMethod").value;
    if (method === "Bank Transfer") document.getElementById("donateStep3Bank").style.display = "block";
    if (method === "Card Payment")  document.getElementById("donateStep3Card").style.display = "block";
  }
  [1, 2, 3].forEach((i) => {
    const dot = document.getElementById("stepDot" + i);
    if (!dot) return;
    dot.classList.remove("active", "done");
    if (i < n)   dot.classList.add("done");
    if (i === n) dot.classList.add("active");
  });
}

function donateNext(fromStep) {
  if (fromStep === 1) {
    const name    = document.getElementById("donorName").value.trim();
    const email   = document.getElementById("donorEmail").value.trim();
    const phone   = document.getElementById("donorPhone").value.trim();
    const address = document.getElementById("donorAddress").value.trim();
    if (!name)    { showToast("Please enter your full name.");     return; }
    if (!email)   { showToast("Please enter your email address."); return; }
    if (!phone)   { showToast("Please enter your phone number.");  return; }
    if (!address) { showToast("Please enter your address.");       return; }
    gotoStep(2);
  } else if (fromStep === 2) {
    const amount = parseFloat(document.getElementById("donateAmount").value);
    const method = document.getElementById("paymentMethod").value;
    const c = campaigns.find((x) => x.id === activeCampaignId);
    
    if (!amount || amount < 1) { showToast("Minimum donation amount is ₹ 1."); return; }
    
    // Get smart limits
    const remaining = c.remaining_to_goal || (c.goal - c.raised);
    const transactionLimit = c.transaction_limit || 10000;
    const maxAllowed = c.max_allowed_donation || Math.min(remaining, transactionLimit);
    
    // Check per-transaction limit
    if (amount > transactionLimit) {
      showToast(`Maximum donation per transaction is ₹${transactionLimit.toLocaleString()}. For larger donations, please make multiple transactions.`);
      return;
    }
    
    // Check remaining goal amount
    if (amount > remaining) {
      showToast(`This campaign only needs ₹${remaining.toLocaleString()} more to reach its goal. Please reduce your donation amount.`);
      return;
    }
    
    if (!method) { showToast("Please select a payment method."); return; }
    gotoStep(3);
  }
}

function donatePrev(fromStep) {
  if (fromStep === 2) gotoStep(1);
  if (fromStep === 3) gotoStep(2);
}

function setAmount(val) {
  document.getElementById("donateAmount").value = val;
  document.querySelectorAll(".amt-btn").forEach((b) =>
    b.classList.toggle("active", parseInt(b.textContent.replace("₹ ", "")) === val)
  );
}

function clearAmountBtns() {
  document.querySelectorAll(".amt-btn").forEach((b) => b.classList.remove("active"));
}

function formatCardNumber(input) {
  let v = input.value.replace(/\D/g, "").substring(0, 16);
  input.value = v.replace(/(.{4})/g, "$1 ").trim();
}

function formatExpiry(input) {
  let v = input.value.replace(/\D/g, "").substring(0, 4);
  if (v.length >= 3) v = v.substring(0, 2) + "/" + v.substring(2);
  input.value = v;
}

async function confirmDonation() {
  const amount  = parseFloat(document.getElementById("donateAmount").value);
  const name    = document.getElementById("donorName").value.trim();
  const email   = document.getElementById("donorEmail").value.trim();
  const phone   = document.getElementById("donorPhone").value.trim();
  const address = document.getElementById("donorAddress").value.trim();
  const method  = document.getElementById("paymentMethod").value;

  let paymentDetails = {};

  if (method === "Bank Transfer") {
    const bankName  = document.getElementById("bankName").value.trim();
    const accName   = document.getElementById("bankAccountName").value.trim();
    const accNum    = document.getElementById("bankAccountNumber").value.trim();
    const ifsc      = document.getElementById("bankIfsc").value.trim();
    const remarks   = document.getElementById("bankRemarks").value.trim();
    if (!bankName) { showToast("Please enter the bank name.");           return; }
    if (!accName)  { showToast("Please enter the account holder name."); return; }
    if (!accNum)   { showToast("Please enter the account number.");      return; }
    if (!ifsc)     { showToast("Please enter the IFSC / SWIFT code.");   return; }
    paymentDetails = { bank_name: bankName, account_name: accName, account_number: accNum, ifsc_code: ifsc, remarks };

  } else if (method === "Card Payment") {
    const cardName = document.getElementById("cardName").value.trim();
    const cardNum  = document.getElementById("cardNumber").value.replace(/\s/g, "");
    const expiry   = document.getElementById("cardExpiry").value.trim();
    const cvv      = document.getElementById("cardCvv").value.trim();
    const cardType = document.getElementById("cardType").value;
    if (!cardName)              { showToast("Please enter the cardholder name."); return; }
    if (cardNum.length < 15)    { showToast("Please enter a valid card number."); return; }
    if (!/^\d{2}\/\d{2}$/.test(expiry)) { showToast("Please enter expiry as MM/YY."); return; }
    if (cvv.length < 3)         { showToast("Please enter a valid CVV.");          return; }
    // Only last 4 digits stored — never the full card number
    paymentDetails = { card_type: cardType, card_last4: cardNum.slice(-4), expiry, card_name: cardName };
  }

  const c = campaigns.find((x) => x.id === activeCampaignId);

  // Show payment processing animation
  const processingOverlay = document.getElementById("paymentProcessing");
  const processingText = document.getElementById("paymentProcessingText");
  const processingSubtext = document.getElementById("paymentProcessingSubtext");
  
  processingOverlay.classList.remove("success");
  processingOverlay.classList.add("show");
  processingText.textContent = "Processing your payment...";
  processingSubtext.textContent = "Please do not close this window";

  // Simulate payment processing delay (2-3 seconds)
  const processingDelay = 2000 + Math.random() * 1000; // 2-3 seconds
  
  // Wait for animation
  await new Promise(resolve => setTimeout(resolve, processingDelay));

  const { ok, data } = await apiFetch(`${API}/donate.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      campaign_id:     activeCampaignId,
      donor_name:      name,
      donor_email:     email,
      donor_phone:     phone,
      donor_address:   address,
      amount,
      payment_method:  method,
      payment_details: paymentDetails,
      user_id:         currentUser?.id || null,
    }),
  });

  if (!ok) { 
    // Hide processing overlay on error
    processingOverlay.classList.remove("show");
    showToast(data.error || "Donation failed. Please try again."); 
    return; 
  }

  // Show success state
  processingOverlay.classList.add("success");
  processingText.textContent = "Payment successful!";
  processingSubtext.textContent = "Thank you for your generosity";
  
  // Wait for success animation (1 second)
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Hide processing overlay
  processingOverlay.classList.remove("show", "success");

  closeModal("donateModal");

  // Receipt
  document.getElementById("receiptId").textContent     = data.receipt_id;
  document.getElementById("receiptAmount").textContent = "₹ " + amount.toLocaleString();
  document.getElementById("receiptEmail").textContent  = email;
  document.getElementById("receiptDetails").innerHTML  = `
    <div class="receipt-row"><span class="receipt-label">Campaign</span><span class="receipt-val">${escapeHTML(c?.title ?? "")}</span></div>
    <div class="receipt-row"><span class="receipt-label">NGO</span><span class="receipt-val">${escapeHTML(c?.ngo ?? "")}</span></div>
    <div class="receipt-row"><span class="receipt-label">Donor</span><span class="receipt-val">${escapeHTML(name)}</span></div>
    <div class="receipt-row"><span class="receipt-label">Payment</span><span class="receipt-val">${escapeHTML(method)}</span></div>
    <div class="receipt-row"><span class="receipt-label">Date</span><span class="receipt-val">${new Date().toLocaleDateString("en-GB")}</span></div>`;
  openModal("receiptModal");

  await loadCampaigns();
  if (currentPage === "home")             await renderHomeGrid();
  if (currentPage === "campaigns")        await renderCampaigns();
  if (currentPage === "admin-donations")  await renderAdminDonations();
  if (currentPage === "trustee")          await renderTrustee();
}

/* ─────────────────────────────────────────────────────
   NGO HISTORY MODAL
───────────────────────────────────────────────────── */
async function openNgoHistory(id) {
  const c = campaigns.find((x) => x.id === id);
  if (!c) return;

  // Fetch history from API
  const ngoName = encodeURIComponent(c.ngo);
  const { ok, data } = await apiFetch(`${API}/ngo_history.php?ngo_name=${ngoName}`);
  
  if (!ok || !data || data.length === 0) {
    showToast("No history available for this NGO yet.");
    return;
  }

  document.getElementById("ngoHistImg").src = c.image || "";
  document.getElementById("ngoHistImg").alt = escapeHTML(c.title);
  document.getElementById("ngoHistTitle").textContent = c.ngo;
  document.getElementById("ngoHistSub").textContent =
    c.title + " · " + c.category;

  document.getElementById("ngoHistBody").innerHTML = data
    .map(
      (h) => `
    <div class="history-record">
      <div class="history-record-title">${escapeHTML(h.title)} (${escapeHTML(h.year)})</div>
      <div class="history-record-grid">
        <div class="history-stat"><div class="history-stat-val">₹ ${parseFloat(h.raised).toLocaleString()}</div><div class="history-stat-label">Total Raised</div></div>
        <div class="history-stat"><div class="history-stat-val">₹ ${parseFloat(h.distributed).toLocaleString()}</div><div class="history-stat-label">Funds Distributed</div></div>
        <div class="history-stat"><div class="history-stat-val">${escapeHTML(h.beneficiaries)}</div><div class="history-stat-label">Beneficiaries</div></div>
        <div class="history-stat"><div class="history-stat-val" style="font-size:13px">${escapeHTML(h.period)}</div><div class="history-stat-label">Campaign Period</div></div>
      </div>
      <div class="history-note">📝 ${escapeHTML(h.note)}</div>
    </div>`,
    )
    .join("");

  openModal("ngoHistoryModal");
}

/* ─────────────────────────────────────────────────────
   ADD CAMPAIGN (Admin)
───────────────────────────────────────────────────── */
function openAddModal() {
  ["newTitle", "newNgo", "newGoal", "newDesc", "newImageUrl"].forEach(
    (id) => (document.getElementById(id).value = ""),
  );
  const fi = document.getElementById("newImageFile");
  if (fi) fi.value = "";
  const prev = document.getElementById("newImagePreview");
  if (prev) prev.innerHTML = "";
  switchImgTab("new", "url");
  document.getElementById("newCategory").value = "Education";
  document.getElementById("aiBox").style.display = "none";
  document.getElementById("aiBtn").style.display = "none";
  aiGeneratedDesc = "";
  openModal("addModal");
}

function checkAiBtn() {
  document.getElementById("aiBtn").style.display = document
    .getElementById("newTitle")
    .value.trim()
    ? "inline-flex"
    : "none";
}

async function generateAiDesc() {
  const title = document.getElementById("newTitle").value.trim();
  if (!title) return;
  document.getElementById("aiSpinner").style.display = "inline-block";
  document.getElementById("aiBtnText").textContent = "Generating…";
  document.getElementById("aiBox").style.display = "none";
  try {
    // Use server-side proxy to keep API key secure
    const { ok, data } = await apiFetch(`${API}/ai_proxy.php`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title }),
    });
    
    if (ok && data.description) {
      aiGeneratedDesc = data.description;
    } else {
      aiGeneratedDesc = data.error || "Could not generate — try again.";
    }
  } catch {
    aiGeneratedDesc = "Network error. Please check your connection.";
  }
  document.getElementById("aiBoxText").textContent = aiGeneratedDesc;
  document.getElementById("aiBox").style.display = "block";
  document.getElementById("aiSpinner").style.display = "none";
  document.getElementById("aiBtnText").textContent = "✦ AI: Regenerate";
}

function useAiDesc() {
  document.getElementById("newDesc").value = aiGeneratedDesc;
  document.getElementById("aiBox").style.display = "none";
  showToast("AI description applied!");
}

async function createCampaign() {
  const title = document.getElementById("newTitle").value.trim();
  const ngoName = document.getElementById("newNgo").value.trim();
  const goal = parseInt(document.getElementById("newGoal").value) || 10000;
  const desc =
    document.getElementById("newDesc").value.trim() ||
    "A new campaign making a difference.";
  const category = document.getElementById("newCategory").value;
  const imageUrl = document.getElementById("newImageUrl").value.trim();
  
  // Get max donation (optional)
  const maxDonationField = document.getElementById("newMaxDonation");
  const maxDonation = maxDonationField && maxDonationField.value.trim() !== '' 
    ? parseFloat(maxDonationField.value) 
    : null;

  if (!title || !ngoName) {
    showToast("Please fill in the title and NGO name.");
    return;
  }

  const { ok, data } = await apiFetch(`${API}/admin_campaigns.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      title,
      ngo_name: ngoName,
      category,
      goal,
      description: desc,
      image_url: imageUrl,
      max_donation: maxDonation,
    }),
  });

  if (!ok) {
    showToast(data.error || "Could not create campaign.");
    return;
  }

  closeModal("addModal");
  await renderAdminCampaigns();
  showToast("Campaign created successfully!");
}

/* ─────────────────────────────────────────────────────
   EDIT CAMPAIGN (Admin)
───────────────────────────────────────────────────── */
function openEditModal(id) {
  const c = campaigns.find((x) => x.id === id);
  if (!c) {
    showToast("Campaign not found.");
    return;
  }
  document.getElementById("editId").value = c.id;
  document.getElementById("editTitle").value = c.title;
  document.getElementById("editNgo").value = c.ngo;
  document.getElementById("editCategory").value = c.category;
  document.getElementById("editGoal").value = c.goal;
  document.getElementById("editDesc").value = c.desc;
  document.getElementById("editImageUrl").value = c.image || "";
  
  // Set max donation field if it exists
  const maxDonationField = document.getElementById("editMaxDonation");
  if (maxDonationField) {
    maxDonationField.value = c.maxDonation !== null ? c.maxDonation : "";
  }
  
  // Reset to URL tab and clear file input
  switchImgTab("edit", "url");
  const fi = document.getElementById("editImageFile");
  if (fi) fi.value = "";
  const prev = document.getElementById("editImagePreview");
  if (prev) prev.innerHTML = c.image
    ? `<img src="${escapeHTML(c.image)}" style="max-height:80px;border-radius:8px;margin-top:6px;object-fit:cover" />`
    : "";
  openModal("editModal");
}

// saveCampaign — change PUT to POST + _method
async function saveCampaign() {
  const id = parseInt(document.getElementById("editId").value);
  const title = document.getElementById("editTitle").value.trim();
  const category = document.getElementById("editCategory").value;
  const goal = parseInt(document.getElementById("editGoal").value) || 0;
  const desc = document.getElementById("editDesc").value.trim();
  const imageUrl = document.getElementById("editImageUrl").value.trim();
  
  // Get max donation (optional)
  const maxDonationField = document.getElementById("editMaxDonation");
  const maxDonation = maxDonationField && maxDonationField.value.trim() !== '' 
    ? parseFloat(maxDonationField.value) 
    : null;

  const { ok, data } = await apiFetch(`${API}/admin_campaigns.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      _method: "PUT",
      id,
      title,
      category,
      goal,
      description: desc,
      image_url: imageUrl,
      max_donation: maxDonation,
    }),
  });

  if (!ok) {
    showToast(data.error || "Could not update campaign.");
    return;
  }
  closeModal("editModal");
  await renderAdminCampaigns();
  showToast("Campaign updated!");
}

async function deleteCampaign(id) {
  if (!confirm("Are you sure you want to delete this campaign?")) return;

  const { ok, data } = await apiFetch(`${API}/admin_campaigns.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ _method: "DELETE", id }),
  });

  if (!ok) {
    showToast(data.error || "Could not delete campaign.");
    return;
  }
  await renderAdminCampaigns();
  showToast("Campaign deleted.");
}

/* ─────────────────────────────────────────────────────
   IMAGE UPLOAD HELPERS
───────────────────────────────────────────────────── */
function switchImgTab(mode, type) {
  const urlSection  = document.getElementById(mode + "ImgUrlSection");
  const fileSection = document.getElementById(mode + "ImgFileSection");
  const tabUrl      = document.getElementById(mode + "ImgTabUrl");
  const tabFile     = document.getElementById(mode + "ImgTabFile");
  if (!urlSection) return;
  if (type === "url") {
    urlSection.style.display  = "block";
    fileSection.style.display = "none";
    tabUrl.style.background   = "var(--gold)";
    tabUrl.style.color        = "#fff";
    tabFile.style.background  = "var(--bg2)";
    tabFile.style.color       = "var(--text)";
  } else {
    urlSection.style.display  = "none";
    fileSection.style.display = "block";
    tabUrl.style.background   = "var(--bg2)";
    tabUrl.style.color        = "var(--text)";
    tabFile.style.background  = "var(--gold)";
    tabFile.style.color       = "#fff";
  }
}

async function handleImageUpload(input, mode) {
  const file = input.files[0];
  if (!file) return;
  const preview = document.getElementById(mode + "ImagePreview");
  if (preview) preview.innerHTML = '<span style="color:var(--dim);font-size:12px">⏳ Uploading…</span>';

  const formData = new FormData();
  formData.append("image", file);

  try {
    const res  = await fetch(`${API}/upload_image.php`, { method: "POST", body: formData });
    const data = await res.json();
    if (res.ok && data.url) {
      document.getElementById(mode + "ImageUrl").value = data.url;
      if (preview) preview.innerHTML =
        `<img src="${escapeHTML(data.url)}" style="max-height:90px;border-radius:8px;margin-top:6px;object-fit:cover" />`;
    } else {
      if (preview) preview.innerHTML =
        `<span style="color:var(--red);font-size:12px">Upload failed: ${escapeHTML(data.error || "Unknown error")}</span>`;
    }
  } catch {
    if (preview) preview.innerHTML =
      '<span style="color:var(--red);font-size:12px">Upload failed. Is WAMP running?</span>';
  }
}
/* ─────────────────────────────────────────────────────
   ADMIN — SUPPORT MESSAGES
───────────────────────────────────────────────────── */
function formatCountdown(ms) {
  const n = Math.floor(ms / 1000);
  if (!Number.isFinite(n)) return "—";
  if (n <= 0) return "Expired";
  const h = Math.floor(n / 3600);
  const m = Math.floor((n % 3600) / 60);
  const s = n % 60;
  const pad = (x) => String(x).padStart(2, "0");
  return `${pad(h)}:${pad(m)}:${pad(s)}`;
}

async function renderAdminSupport() {
  document.getElementById("adminSupportBody").innerHTML = loadingHTML(7);
  const resolvedBody = document.getElementById("adminResolvedSupportBody");
  if (resolvedBody) resolvedBody.innerHTML = loadingHTML(7);

  const { ok, data } = await apiFetch(`${API}/admin_support.php`);
  if (!ok) {
    document.getElementById("adminSupportBody").innerHTML =
      `<tr><td colspan="7" style="text-align:center;padding:40px;color:var(--red)">Could not load messages.</td></tr>`;
    if (resolvedBody) {
      resolvedBody.innerHTML =
        `<tr><td colspan="7" style="text-align:center;padding:40px;color:var(--red)">Could not load resolved queries.</td></tr>`;
    }
    return;
  }

  const pending = Array.isArray(data?.pending) ? data.pending : [];
  const resolved = Array.isArray(data?.resolved) ? data.resolved : [];

  document.getElementById("supportMsgCount").textContent =
    (data?.pendingCount ?? pending.length) + " messages";
  if (document.getElementById("resolvedSupportMsgCount")) {
    document.getElementById("resolvedSupportMsgCount").textContent =
      (data?.resolvedCount ?? resolved.length) + " resolved";
  }

  // Pending messages (Inbox)
  document.getElementById("adminSupportBody").innerHTML = pending.length
    ? pending
        .map(
          (m) => `
      <tr>
        <td style="font-weight:600">${escapeHTML(m.name)}</td>
        <td style="color:var(--dim);font-size:12px">${escapeHTML(m.email)}</td>
        <td style="color:var(--dim);font-size:12px">${escapeHTML(m.phone)}</td>
        <td><span class="badge badge-pending" style="white-space:nowrap">${escapeHTML(m.category)}</span></td>
        <td style="max-width:220px;white-space:normal;font-size:12px;line-height:1.5">${escapeHTML(m.message)}</td>
        <td style="color:var(--dim);font-size:12px">${escapeHTML(m.submitted_at)}</td>
        <td>
          <select class="status-select" onchange="updateSupportStatus(${m.id}, this.value)">
            <option ${m.status === "Pending" ? "selected" : ""}>Pending</option>
            <option ${m.status === "Resolved" ? "selected" : ""}>Resolved</option>
          </select>
        </td>
      </tr>`,
        )
        .join("")
    : `<tr><td colspan="7" style="text-align:center;padding:40px;color:var(--dim)">No support messages yet.</td></tr>`;

  // Resolved messages (with delete countdown)
  if (resolvedBody) {
    resolvedBody.innerHTML = resolved.length
      ? resolved
          .map(
            (m) => `
        <tr>
          <td style="font-weight:600">${escapeHTML(m.name)}</td>
          <td style="color:var(--dim);font-size:12px">${escapeHTML(m.email)}</td>
          <td style="color:var(--dim);font-size:12px">${escapeHTML(m.phone)}</td>
          <td><span class="badge badge-done" style="white-space:nowrap">Resolved</span></td>
          <td style="max-width:220px;white-space:normal;font-size:12px;line-height:1.5">${escapeHTML(m.message)}</td>
          <td style="color:var(--dim);font-size:12px">${escapeHTML(m.resolved_at || m.submitted_at)}</td>
          <td style="color:var(--dim);font-size:12px;white-space:nowrap">
            <span id="resolvedDeleteTimer-${m.id}">--</span>
          </td>
        </tr>`,
          )
          .join("")
      : `<tr><td colspan="7" style="text-align:center;padding:40px;color:var(--dim)">No resolved queries yet.</td></tr>`;
  }

  // Timer setup for resolved rows
  window._supportResolvedRows = resolved;
  clearInterval(window._supportResolvedTimerInterval);

  const updateResolvedTimers = () => {
    if (!Array.isArray(window._supportResolvedRows)) return;
    const now = Date.now();
    let expired = false;
    for (const m of window._supportResolvedRows) {
      const span = document.getElementById(`resolvedDeleteTimer-${m.id}`);
      if (!span) continue;
      const deleteAtMs = parseInt(m.delete_at_ms, 10);
      if (!Number.isFinite(deleteAtMs)) {
        span.textContent = "—";
        continue;
      }
      const remaining = deleteAtMs - now;
      if (remaining <= 0) expired = true;
      span.textContent = formatCountdown(remaining);
    }

    // Purge happens server-side on next GET; refresh when something expires.
    if (expired && !window._supportResolvedRefreshQueued) {
      window._supportResolvedRefreshQueued = true;
      renderAdminSupport()
        .catch(() => {})
        .finally(() => {
          window._supportResolvedRefreshQueued = false;
        });
    }
  };

  window._supportResolvedTimerInterval = setInterval(updateResolvedTimers, 1000);
  updateResolvedTimers();
}

async function updateSupportStatus(id, status) {
  const { ok, data } = await apiFetch(`${API}/admin_support.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ id, status }),
  });
  if (!ok) {
    showToast(data.error || "Could not update status.");
    return;
  }
  showToast("Status updated to " + status + ".");
  // Refresh so resolved section + timers reflect the new status.
  await renderAdminSupport();
}

/* ─────────────────────────────────────────────────────
   SUPPORT FORM
───────────────────────────────────────────────────── */
async function submitSupport() {
  const name = document.getElementById("suppName").value.trim();
  const email = document.getElementById("suppEmail").value.trim();
  const phone = document.getElementById("suppPhone").value.trim();
  const cat = document.getElementById("suppCat").value;
  const message = document.getElementById("suppQuery").value.trim();

  if (!name || !email || !phone || !cat || !message) {
    showToast("Please fill in all fields.");
    return;
  }

  const { ok, data } = await apiFetch(`${API}/support.php`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email, phone, category: cat, message, website: "" }), // website is honeypot field
  });

  if (!ok) {
    showToast(data.error || "Failed to send message. Please try again.");
    return;
  }

  document.getElementById("supportSuccess").classList.add("show");
  ["suppName", "suppEmail", "suppPhone", "suppQuery"].forEach(
    (id) => (document.getElementById(id).value = ""),
  );
  document.getElementById("suppCat").value = "";
  setTimeout(
    () => document.getElementById("supportSuccess").classList.remove("show"),
    5000,
  );
}

/* ─────────────────────────────────────────────────────
   MODAL HELPERS
───────────────────────────────────────────────────── */
function openModal(id) {
  document.getElementById(id).classList.add("open");
}
function closeModal(id) {
  document.getElementById(id).classList.remove("open");
}

/* ─────────────────────────────────────────────────────
   TOAST
───────────────────────────────────────────────────── */
function showToast(msg) {
  const t = document.getElementById("toast");
  t.textContent = msg;
  t.classList.add("show");
  setTimeout(() => t.classList.remove("show"), 3200);
}

/* ─────────────────────────────────────────────────────
   INIT — defer until DOM is ready (script is in <head>)
   This fixes: Featured Campaigns blank on first visit,
               modal-overlay click-outside not working.
───────────────────────────────────────────────────── */
document.addEventListener("DOMContentLoaded", async () => {
  document.querySelectorAll(".modal-overlay").forEach((o) => {
    o.addEventListener("click", (e) => {
      if (e.target === o) o.classList.remove("open");
    });
  });

  // Check server session instead of localStorage
  const isAuthenticated = await checkSession();
  
  // Start session monitoring if logged in
  if (isAuthenticated) {
    startSessionMonitor();
  }

  // Route to the appropriate landing page based on role
  if (currentUser) {
    if (currentUser.role === "admin") {
      switchPage("admin-campaigns");
    } else if (currentUser.role === "trustee") {
      switchPage("trustee");
    } else {
      switchPage("home");
    }
  } else {
    switchPage("home");
  }
});