##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

output "server_name" {
  description = "The name of the MSSQL Server."
  value       = azurerm_mssql_server.this.name
}

output "server_id" {
  description = "The ID of the MSSQL Server."
  value       = azurerm_mssql_server.this.id
}

output "fqdn" {
  description = "The FQDN of the MSSQL Server."
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "resource_group_name" {
  description = "The resource group name where the server was deployed."
  value       = azurerm_resource_group.this.name
}

output "default_database_name" {
  description = "The default database name."
  value       = azurerm_mssql_database.default.name
}

output "administrator_login" {
  description = "The administrator login username."
  value       = local.admin_login
}

output "credentials_secret_name" {
  description = "The Azure Key Vault secret name storing the master credentials JSON."
  value       = azurerm_key_vault_secret.master_credentials.name
}
