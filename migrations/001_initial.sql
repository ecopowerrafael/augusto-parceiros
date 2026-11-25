CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  role VARCHAR(24) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'ACTIVE',
  name VARCHAR(180) NOT NULL,
  cpf VARCHAR(14) NULL,
  email VARCHAR(255) NOT NULL,
  whatsapp VARCHAR(30) NULL,
  password_hash VARCHAR(255) NOT NULL,
  terms_accepted_at DATETIME NULL,
  privacy_acknowledged_at DATETIME NULL,
  approved_at DATETIME NULL,
  approved_by CHAR(36) NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_cpf (cpf),
  KEY idx_users_role_status (role, status),
  CONSTRAINT fk_users_approved_by FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS partner_companies (
  id CHAR(36) NOT NULL PRIMARY KEY,
  person_type VARCHAR(2) NOT NULL,
  legal_name VARCHAR(180) NOT NULL,
  trade_name VARCHAR(180) NULL,
  cpf_cnpj VARCHAR(18) NOT NULL,
  responsible_name VARCHAR(180) NOT NULL,
  email VARCHAR(255) NOT NULL,
  whatsapp VARCHAR(30) NOT NULL,
  zip_code VARCHAR(10) NULL,
  address VARCHAR(180) NULL,
  address_number VARCHAR(20) NULL,
  complement VARCHAR(120) NULL,
  neighborhood VARCHAR(120) NULL,
  city VARCHAR(120) NULL,
  state CHAR(2) NULL,
  segment VARCHAR(80) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'PENDING',
  rejection_reason VARCHAR(500) NULL,
  approved_at DATETIME NULL,
  approved_by CHAR(36) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_partner_cpf_cnpj (cpf_cnpj),
  KEY idx_partner_status_created (status, created_at),
  CONSTRAINT fk_partner_approved_by FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS company_members (
  company_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  company_role VARCHAR(24) NOT NULL DEFAULT 'COLLABORATOR',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (company_id, user_id),
  KEY idx_members_user (user_id),
  CONSTRAINT fk_members_company FOREIGN KEY (company_id) REFERENCES partner_companies(id) ON DELETE CASCADE,
  CONSTRAINT fk_members_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS client_profiles (
  user_id CHAR(36) NOT NULL PRIMARY KEY,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_client_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sessions (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  csrf_token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL,
  user_agent VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_sessions_token (token_hash),
  KEY idx_sessions_user_active (user_id, revoked_at, expires_at),
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_reset_token (token_hash),
  KEY idx_reset_user (user_id, expires_at),
  CONSTRAINT fk_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rate_limit_events (
  bucket_key VARCHAR(180) NOT NULL,
  window_started_at DATETIME NOT NULL,
  attempts INT NOT NULL DEFAULT 0,
  PRIMARY KEY (bucket_key, window_started_at),
  KEY idx_rate_limit_window (window_started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  actor_user_id CHAR(36) NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id CHAR(36) NULL,
  metadata JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_audit_actor_created (actor_user_id, created_at),
  KEY idx_audit_entity_created (entity_type, entity_id, created_at),
  CONSTRAINT fk_audit_actor FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
