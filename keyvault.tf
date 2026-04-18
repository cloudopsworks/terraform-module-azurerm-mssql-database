##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  kv_secret_name = lower(replace("${local.system_name_short}-mssql-${local.server_name}-master", "/[^a-zA-Z0-9-]/", "-"))
  master_credentials = {
    username    = local.admin_login
    password    = random_password.master.result
    host        = azurerm_mssql_server.this.fully_qualified_domain_name
    port        = 1433
    dbname      = local.default_db_name
    engine      = "sqlserver"
    server_name = local.server_name
  }
}

data "azurerm_key_vault" "credentials" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

resource "azurerm_key_vault_secret" "master_credentials" {
  name         = local.kv_secret_name
  value        = jsonencode(local.master_credentials)
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "application/json"
  tags = merge(local.all_tags, {
    "mssql-server" = local.server_name
    "mssql-db"     = local.default_db_name
  })
}
