resource "random_integer" "zone_index" {
  count = length(local.region_zones) > 0 ? 1 : 0

  max = length(local.region_zones)
  min = 1
}

resource "random_password" "jumpvm_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "jumpvm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.19.3"
  count   = var.flag_platform_landing_zone && var.jumpvm_definition.deploy ? 1 : 0

  location = azurerm_resource_group.this.location
  name     = local.jump_vm_name
  network_interfaces = {
    network_interface_1 = {
      name = "${local.jump_vm_name}-nic1"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${local.jump_vm_name}-nic1-ipconfig1"
          private_ip_subnet_resource_id = module.ai_lz_vnet.subnets["JumpboxSubnet"].resource_id
        }
      }
    }
  }
  resource_group_name = azurerm_resource_group.this.name
  zone                = length(local.region_zones) > 0 ? random_integer.zone_index[0].result : null

  # Using explicit password instead of Key Vault to avoid data plane access issues during deployment
  # when public network access is disabled on the Key Vault.
  admin_password = "P0rb@nd@r!980"
  os_type = "Windows"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  admin_username = "azureuser"

  enable_telemetry = var.enable_telemetry
  sku_size         = var.jumpvm_definition.sku
  tags             = var.jumpvm_definition.tags
  encryption_at_host_enabled = false

  managed_identities = {
    system_assigned = true
  }

  depends_on = [module.avm_res_keyvault_vault]
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count = var.flag_platform_landing_zone && var.jumpvm_definition.deploy ? 1 : 0

  name                       = "AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  virtual_machine_id         = module.jumpvm[0].resource_id
  auto_upgrade_minor_version = true
}



