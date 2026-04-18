##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  server_name     = try(var.settings.name_prefix, "") != "" ? "${local.system_name_short}-${var.settings.name_prefix}" : local.system_name_short
  admin_login     = try(var.settings.administrator_login, "sqladmin")
  default_db_name = try(var.settings.database.name, "master")
}

resource "azurerm_resource_group" "this" {
  name     = "${local.system_name}-mssql-rg"
  location = var.region
  tags     = local.all_tags
}

resource "random_password" "master" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "azurerm_mssql_server" "this" {
  name                          = local.server_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  version                       = try(var.settings.version, "12.0")
  administrator_login           = local.admin_login
  administrator_login_password  = random_password.master.result
  minimum_tls_version           = try(var.settings.minimum_tls_version, "1.2")
  public_network_access_enabled = try(var.network.public_network_access, true)
  connection_policy             = try(var.settings.connection_policy, "Default")
  tags                          = local.all_tags
}

resource "azurerm_mssql_database" "default" {
  name            = local.default_db_name
  server_id       = azurerm_mssql_server.this.id
  sku_name        = try(var.settings.database.sku_name, "Basic")
  max_size_gb     = try(var.settings.database.max_size_gb, 2)
  collation       = try(var.settings.database.collation, "SQL_Latin1_General_CP1_CI_AS")
  elastic_pool_id = try(var.settings.database.elastic_pool_id, null)
  zone_redundant  = try(var.settings.database.zone_redundant, false)
  tags            = local.all_tags
}

resource "azurerm_mssql_database" "additional" {
  for_each        = try(var.settings.databases, {})
  name            = each.value.name
  server_id       = azurerm_mssql_server.this.id
  sku_name        = try(each.value.sku_name, "Basic")
  max_size_gb     = try(each.value.max_size_gb, 2)
  collation       = try(each.value.collation, "SQL_Latin1_General_CP1_CI_AS")
  elastic_pool_id = try(each.value.elastic_pool_id, null)
  zone_redundant  = try(each.value.zone_redundant, false)
  tags            = local.all_tags
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each         = { for r in try(var.network.firewall_rules, []) : r.name => r }
  name             = each.value.name
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

resource "azurerm_mssql_virtual_network_rule" "this" {
  for_each  = { for r in try(var.network.vnet_rules, []) : r.name => r }
  name      = each.value.name
  server_id = azurerm_mssql_server.this.id
  subnet_id = each.value.subnet_id
}
