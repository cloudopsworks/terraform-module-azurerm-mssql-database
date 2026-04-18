##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## YAML Input Format
# settings:
#   name_prefix: "mydb"                # (Required) Name prefix for the SQL Server resource.
#   version: "12.0"                    # (Optional) SQL Server version. Currently only "12.0" is supported (SQL Server 2014+). Default: "12.0".
#   administrator_login: "sqladmin"    # (Optional) Admin username. Default: "sqladmin".
#   minimum_tls_version: "1.2"         # (Optional) Minimum TLS version. Possible values: 1.0, 1.1, 1.2, Disabled. Default: 1.2.
#   connection_policy: "Default"       # (Optional) Connection policy. Possible values: Default, Proxy, Redirect. Default: Default.
#   database:                          # (Optional) Default database settings.
#     name: "master"                   # (Optional) Default database name. Default: "master".
#     sku_name: "Basic"                # (Optional) DTU/vCore SKU. Possible values: Basic, S0..S12, GP_S_Gen5_1, BC_Gen5_2, etc. Default: Basic.
#     max_size_gb: 2                   # (Optional) Max database size in GB. Default: 2.
#     collation: "SQL_Latin1_General_CP1_CI_AS" # (Optional) Collation. Default: SQL_Latin1_General_CP1_CI_AS.
#     elastic_pool_id: ""              # (Optional) Elastic pool resource ID if using elastic pools.
#     zone_redundant: false            # (Optional) Zone redundancy. Default: false.
#   databases: {}                      # (Optional) Map of additional databases.
#     <key>:
#       name: ""                       # (Required) Database name.
#       sku_name: "Basic"              # (Optional) DTU/vCore SKU. Default: Basic.
#       max_size_gb: 2                 # (Optional) Max database size in GB. Default: 2.
#       collation: "SQL_Latin1_General_CP1_CI_AS" # (Optional) Collation. Default: SQL_Latin1_General_CP1_CI_AS.
#       elastic_pool_id: ""            # (Optional) Elastic pool resource ID.
#       zone_redundant: false          # (Optional) Zone redundancy. Default: false.
#   auditing:
#     enabled: false                   # (Optional) Enable server audit logging. Default: false.
#     retention_days: 90               # (Optional) Audit log retention days. Default: 90.
#   hoop:
#     enabled: false                   # (Optional) Generate hoop_connections output. Default: false.
#     agent_id: ""                     # (Required when enabled) Hoop agent UUID.
#     community: true                  # (Optional) true=community (null output); false=enterprise. Default: true.
#     import: false                    # (Optional) Import existing Hoop connection. Default: false.
#     tags: {}                         # (Optional) Tags map applied to Hoop connection.
#     access_control: []               # (Optional) Access control groups list.
variable "settings" {
  description = "Settings for Azure SQL Server (MSSQL) — see inline docs for full YAML structure."
  type        = any
  default     = {}
}

## YAML Input Format
# network:
#   public_network_access: true      # (Optional) Allow public network access. Default: true.
#   firewall_rules:                  # (Optional) List of firewall rules.
#     - name: "office"               # (Required) Rule name.
#       start_ip: "203.0.113.0"      # (Required) Start IP address.
#       end_ip: "203.0.113.255"      # (Required) End IP address.
#   vnet_rules:                      # (Optional) List of VNet rules.
#     - name: "subnet-rule"          # (Required) Rule name.
#       subnet_id: "/subscriptions/.../subnets/db" # (Required) Subnet resource ID.
variable "network" {
  description = "Network configuration for Azure SQL Server — firewall rules, VNet rules, and public access."
  type        = any
  default     = {}
}

variable "key_vault_name" {
  description = "(Required) Name of the existing Azure Key Vault for credential storage."
  type        = string
}

variable "key_vault_resource_group_name" {
  description = "(Required) Resource group name of the existing Azure Key Vault."
  type        = string
}
