# Contributing to Donare

Thank you for considering contributing to Donare! This document outlines how to contribute to the project effectively.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Submitting a Pull Request](#submitting-a-pull-request)
- [Code Style Guidelines](#code-style-guidelines)
- [Reporting Bugs](#reporting-bugs)
- [Requesting Features](#requesting-features)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment. Be kind, constructive, and professional in all interactions.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/donare-v.git
   cd donare-v
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/donare-v.git
   ```

## Development Setup

1. **Install prerequisites**:
   - PHP 8.0+
   - MySQL 8.0+
   - Apache (WAMP/XAMPP/LAMP)

2. **Set up the database**:
   ```bash
   mysql -u root -p < donare_db.sql
   ```

3. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your local settings
   ```

4. **Start your local server** and access at `http://localhost/donare-v/donare.html`

## Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes** following our [code style guidelines](#code-style-guidelines)

3. **Test your changes** thoroughly

4. **Commit with clear messages**:
   ```bash
   git commit -m "Add: Description of feature"
   # or
   git commit -m "Fix: Description of bug fix"
   ```

## Submitting a Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a Pull Request** on GitHub with:
   - Clear title describing the change
   - Description of what was changed and why
   - Screenshots for UI changes
   - Reference to any related issues

3. **Respond to feedback** and make requested changes

## Code Style Guidelines

### PHP
- Follow **PSR-12** coding standards
- Use 4-space indentation
- Use prepared statements for all database queries
- Sanitize all user inputs

```php
// Good
$stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
$stmt->bind_param('i', $userId);

// Bad
$conn->query("SELECT * FROM users WHERE id = $userId");
```

### JavaScript
- Use 2-space indentation
- Use `const` and `let` (not `var`)
- Use template literals for string concatenation
- Use async/await for asynchronous operations

```javascript
// Good
const fetchCampaigns = async () => {
  const response = await fetch(`${API}/campaigns.php`);
  return response.json();
};

// Bad
var fetchCampaigns = function() {
  return fetch(API + '/campaigns.php').then(function(r) { return r.json(); });
};
```

### CSS
- Use 2-space indentation
- Use CSS custom properties (variables) for colors
- Mobile-first responsive design
- BEM naming convention where appropriate

### HTML
- Use semantic HTML5 elements
- Include proper ARIA attributes for accessibility
- Validate HTML before submitting

## Reporting Bugs

When reporting bugs, please include:

1. **Description**: Clear description of the issue
2. **Steps to Reproduce**:
   - Step 1
   - Step 2
   - etc.
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Screenshots**: If applicable
6. **Environment**:
   - Browser and version
   - PHP version
   - MySQL version
   - Operating system

## Requesting Features

Feature requests are welcome! Please:

1. **Check existing issues** to avoid duplicates
2. **Provide clear description** of the feature
3. **Explain the use case** and why it would be valuable
4. **Consider implementation** suggestions if applicable

---

Thank you for contributing to Donare! Your help makes this project better for everyone. 🎗️
