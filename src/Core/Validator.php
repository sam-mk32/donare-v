<?php
/**
 * Input Validator Class
 * 
 * Provides common validation methods for API inputs.
 */

namespace Donare\Core;

class Validator
{
    private array $errors = [];
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public static function make(array $data): self
    {
        return new self($data);
    }

    public function required(string $field, string $message = null): self
    {
        if (!isset($this->data[$field]) || trim($this->data[$field]) === '') {
            $this->errors[$field] = $message ?? "{$field} is required";
        }
        return $this;
    }

    public function email(string $field, string $message = null): self
    {
        if (isset($this->data[$field]) && !filter_var($this->data[$field], FILTER_VALIDATE_EMAIL)) {
            $this->errors[$field] = $message ?? "{$field} must be a valid email address";
        }
        return $this;
    }

    public function numeric(string $field, string $message = null): self
    {
        if (isset($this->data[$field]) && !is_numeric($this->data[$field])) {
            $this->errors[$field] = $message ?? "{$field} must be a number";
        }
        return $this;
    }

    public function min(string $field, float $min, string $message = null): self
    {
        if (isset($this->data[$field]) && is_numeric($this->data[$field]) && $this->data[$field] < $min) {
            $this->errors[$field] = $message ?? "{$field} must be at least {$min}";
        }
        return $this;
    }

    public function max(string $field, float $max, string $message = null): self
    {
        if (isset($this->data[$field]) && is_numeric($this->data[$field]) && $this->data[$field] > $max) {
            $this->errors[$field] = $message ?? "{$field} must not exceed {$max}";
        }
        return $this;
    }

    public function minLength(string $field, int $length, string $message = null): self
    {
        if (isset($this->data[$field]) && strlen($this->data[$field]) < $length) {
            $this->errors[$field] = $message ?? "{$field} must be at least {$length} characters";
        }
        return $this;
    }

    public function maxLength(string $field, int $length, string $message = null): self
    {
        if (isset($this->data[$field]) && strlen($this->data[$field]) > $length) {
            $this->errors[$field] = $message ?? "{$field} must not exceed {$length} characters";
        }
        return $this;
    }

    public function in(string $field, array $values, string $message = null): self
    {
        if (isset($this->data[$field]) && !in_array($this->data[$field], $values)) {
            $this->errors[$field] = $message ?? "{$field} must be one of: " . implode(', ', $values);
        }
        return $this;
    }

    public function phone(string $field, string $message = null): self
    {
        if (isset($this->data[$field])) {
            $cleaned = preg_replace('/[^0-9+]/', '', $this->data[$field]);
            if (strlen($cleaned) < 10 || strlen($cleaned) > 15) {
                $this->errors[$field] = $message ?? "{$field} must be a valid phone number";
            }
        }
        return $this;
    }

    public function fails(): bool
    {
        return !empty($this->errors);
    }

    public function passes(): bool
    {
        return empty($this->errors);
    }

    public function errors(): array
    {
        return $this->errors;
    }

    public function firstError(): ?string
    {
        return $this->errors ? reset($this->errors) : null;
    }

    public static function sanitize(string $value): string
    {
        return htmlspecialchars(trim($value), ENT_QUOTES, 'UTF-8');
    }

    public static function sanitizeArray(array $data): array
    {
        return array_map(function ($value) {
            return is_string($value) ? self::sanitize($value) : $value;
        }, $data);
    }
}
