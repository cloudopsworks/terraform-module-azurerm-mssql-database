##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  hoop_enabled    = try(var.settings.hoop.enabled, false)
  hoop_enterprise = local.hoop_enabled && !try(var.settings.hoop.community, true)
  hoop_kv_prefix  = lower(replace("${local.system_name_short}-mssql-${local.server_name}-hoop", "/[^a-zA-Z0-9-]/", "-"))
}

resource "azurerm_key_vault_secret" "hoop_host" {
  count        = local.hoop_enterprise ? 1 : 0
  name         = "${local.hoop_kv_prefix}-host"
  value        = azurerm_mssql_server.this.fully_qualified_domain_name
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "text/plain"
  tags         = local.all_tags
}

resource "azurerm_key_vault_secret" "hoop_port" {
  count        = local.hoop_enterprise ? 1 : 0
  name         = "${local.hoop_kv_prefix}-port"
  value        = "1433"
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "text/plain"
  tags         = local.all_tags
}

resource "azurerm_key_vault_secret" "hoop_user" {
  count        = local.hoop_enterprise ? 1 : 0
  name         = "${local.hoop_kv_prefix}-user"
  value        = local.admin_login
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "text/plain"
  tags         = local.all_tags
}

resource "azurerm_key_vault_secret" "hoop_pass" {
  count        = local.hoop_enterprise ? 1 : 0
  name         = "${local.hoop_kv_prefix}-pass"
  value        = random_password.master.result
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "text/plain"
  tags         = local.all_tags
}

resource "azurerm_key_vault_secret" "hoop_db" {
  count        = local.hoop_enterprise ? 1 : 0
  name         = "${local.hoop_kv_prefix}-db"
  value        = local.default_db_name
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "text/plain"
  tags         = local.all_tags
}

output "hoop_connections" {
  description = "Hoop connection definitions. Enterprise mode only. Community mode returns null."
  value = local.hoop_enterprise ? {
    "owner" = {
      name           = "${local.server_name}-ow"
      agent_id       = try(var.settings.hoop.agent_id, "")
      type           = "database"
      subtype        = "sqlserver"
      tags           = try(var.settings.hoop.tags, {})
      access_control = toset(try(var.settings.hoop.access_control, []))
      access_modes   = { connect = "enabled", exec = "enabled", runbooks = "enabled", schema = "enabled" }
      import         = try(var.settings.hoop.import, false)
      secrets = {
        "envvar:HOST" = "_envs/azure/${azurerm_key_vault_secret.hoop_host[0].name}"
        "envvar:PORT" = "_envs/azure/${azurerm_key_vault_secret.hoop_port[0].name}"
        "envvar:USER" = "_envs/azure/${azurerm_key_vault_secret.hoop_user[0].name}"
        "envvar:PASS" = "_envs/azure/${azurerm_key_vault_secret.hoop_pass[0].name}"
        "envvar:DB"   = "_envs/azure/${azurerm_key_vault_secret.hoop_db[0].name}"
      }
    }
  } : null

  precondition {
    condition     = !local.hoop_enterprise || try(var.settings.hoop.agent_id, "") != ""
    error_message = "settings.hoop.agent_id must be set when hoop enterprise mode is enabled."
  }
}
