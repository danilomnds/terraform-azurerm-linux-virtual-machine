resource "azurerm_network_interface" "nic" {
  for_each                       = var.network_interface != null ? { for k, v in var.network_interface : k => v if v != null } : {}
  name                           = lookup(each.value, "name", null) == null ? lower("${var.name}_${each.key}") : lookup(each.value, "name", null)
  location                       = lookup(each.value, "location", null) == null ? var.location : lookup(each.value, "location", null)
  resource_group_name            = lookup(each.value, "resource_group_name", null) == null ? var.resource_group_name : lookup(each.value, "resource_group_name", null)
  auxiliary_mode                 = lookup(each.value, "auxiliary_mode", null)
  auxiliary_sku                  = lookup(each.value, "auxiliary_sku", null)
  dns_servers                    = lookup(each.value, "dns_servers", null)
  edge_zone                      = lookup(each.value, "edge_zone", null)
  ip_forwarding_enabled          = lookup(each.value, "ip_forwarding_enabled", false)
  internal_dns_name_label        = lookup(each.value, "edge_zone", null)
  tags                           = lookup(each.value, "tags", null) == null ? local.tags_net : lookup(each.value, "tags", null)
  accelerated_networking_enabled = lookup(each.value, "accelerated_networking_enabled", false)
  ip_configuration {
    name                                               = each.value.ip_configuration[0].name
    gateway_load_balancer_frontend_ip_configuration_id = lookup(each.value.ip_configuration[0], "gateway_load_balancer_frontend_ip_configuration_id", null)
    subnet_id                                          = lookup(each.value.ip_configuration[0], "subnet_id", null)
    private_ip_address_version                         = lookup(each.value.ip_configuration[0], "private_ip_address_version", null)
    private_ip_address_allocation                      = each.value.ip_configuration[0].private_ip_address_allocation
    public_ip_address_id                               = lookup(each.value.ip_configuration[0], "public_ip_address_id", null)
    primary                                            = lookup(each.value.ip_configuration[0], "primary", true)
    private_ip_address                                 = lookup(each.value.ip_configuration[0], "private_ip_address", null)
  }
  dynamic "ip_configuration" {
    for_each = length(each.value.ip_configuration) > 1 ? slice(each.value.ip_configuration, 1, length(each.value.ip_configuration)) : []
    content {
      name                                               = ip_configuration.value.name
      gateway_load_balancer_frontend_ip_configuration_id = lookup(ip_configuration.value, "gateway_load_balancer_frontend_ip_configuration_id", null)
      subnet_id                                          = lookup(ip_configuration.value, "subnet_id", null)
      private_ip_address_version                         = lookup(ip_configuration.value, "private_ip_address_version", null)
      private_ip_address_allocation                      = lookup(ip_configuration.value, "private_ip_address_allocation", null)
      public_ip_address_id                               = lookup(ip_configuration.value, "public_ip_address_id", null)
      primary                                            = lookup(ip_configuration.value, "primary", false)
      private_ip_address                                 = lookup(ip_configuration.value, "private_ip_address", null)
    }
  }
  lifecycle {
    ignore_changes = [
      tags["create_date"]
    ]
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  depends_on = [
    azurerm_network_interface.nic
  ]
  location              = var.location
  resource_group_name   = var.resource_group_name
  admin_username        = var.admin_username
  license_type          = var.license_type
  name                  = lower(var.name)
  network_interface_ids = var.network_interface_ids == null ? values(azurerm_network_interface.nic)[*].id : var.network_interface_ids
  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    dynamic "diff_disk_settings" {
      for_each = var.os_disk.diff_disk_settings != null ? [var.os_disk.diff_disk_settings] : []
      content {
        option    = diff_disk_settings.value.option
        placement = lookup(diff_disk_settings.value, "placement", null)
      }
    }
    disk_encryption_set_id           = lookup(var.os_disk, "disk_encryption_set_id", null)
    disk_size_gb                     = lookup(var.os_disk, "disk_size_gb", null)
    name                             = lookup(var.os_disk, "name", null) == null ? "${var.name}_boot_disk" : lookup(var.os_disk, "name", null)
    secure_vm_disk_encryption_set_id = lookup(var.os_disk, "secure_vm_disk_encryption_set_id", null)
    security_encryption_type         = lookup(var.os_disk, "security_encryption_type", null)
    write_accelerator_enabled        = lookup(var.os_disk, "write_accelerator_enabled", null)
  }
  size = var.size
  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities != null ? [var.additional_capabilities] : []
    content {
      ultra_ssd_enabled = lookup(additional_capabilities.value, "ultra_ssd_enabled", false)
      #hibernation_enabled = lookup(additional_capabilities.value, "hibernation_enabled", null)
    }
  }
  admin_password = var.admin_password
  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_key != null ? [var.admin_ssh_key] : []
    content {
      public_key = admin_ssh_key.value.public_key
      username   = admin_ssh_key.value.username
    }
  }
  allow_extension_operations = var.allow_extension_operations
  availability_set_id        = var.availability_set_id
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics != null ? [var.boot_diagnostics] : []
    content {
      storage_account_uri = lookup(boot_diagnostics.value, "storage_account_uri", null)
    }
  }
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled
  capacity_reservation_group_id                          = var.capacity_reservation_group_id
  computer_name                                          = var.computer_name == null ? lower(var.name) : var.computer_name
  custom_data                                            = var.custom_data
  #custom_data = try(filebase64(lookup(local.startup_script, var.ansible)), null)
  dedicated_host_id               = var.dedicated_host_id
  dedicated_host_group_id         = var.dedicated_host_group_id
  disable_password_authentication = var.disable_password_authentication
  disk_controller_type            = var.disk_controller_type
  edge_zone                       = var.edge_zone
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  eviction_policy                 = var.eviction_policy
  extensions_time_budget          = var.extensions_time_budget
  dynamic "gallery_application" {
    for_each = var.gallery_application != null ? [var.gallery_application] : []
    content {
      version_id                                  = gallery_application.value.version_id
      automatic_upgrade_enabled                   = lookup(gallery_application.value, "automatic_upgrade_enabled", false)
      configuration_blob_uri                      = lookup(gallery_application.value, "configuration_blob_uri", null)
      order                                       = lookup(gallery_application.value, "order", 0)
      tag                                         = lookup(gallery_application.value, "tag", null)
      treat_failure_as_deployment_failure_enabled = lookup(gallery_application.value, "treat_failure_as_deployment_failure_enabled", false)
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }
  patch_assessment_mode = var.patch_assessment_mode
  patch_mode            = var.patch_mode
  max_bid_price         = var.max_bid_price
  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }
  platform_fault_domain        = var.platform_fault_domain
  priority                     = var.priority
  provision_vm_agent           = var.provision_vm_agent
  proximity_placement_group_id = var.proximity_placement_group_id
  reboot_setting               = var.reboot_setting
  dynamic "secret" {
    for_each = var.secret != null ? [var.secret] : []
    content {
      dynamic "certificate" {
        for_each = secret.value.certificate != null ? [secret.value.certificate] : []
        content {
          url = certificate.value.url
        }
      }
      key_vault_id = secret.value.key_vault_id
    }
  }
  secure_boot_enabled = var.secure_boot_enabled
  source_image_id     = var.source_image_id
  dynamic "source_image_reference" {
    for_each = var.source_image_reference != null ? [var.source_image_reference] : []
    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }
  tags = local.tags_vm
  dynamic "os_image_notification" {
    for_each = var.os_image_notification != null ? [var.os_image_notification] : []
    content {
      timeout = os_image_notification.value.timeout
    }
  }
  dynamic "termination_notification" {
    for_each = var.termination_notification != null ? [var.termination_notification] : []
    content {
      enabled = termination_notification.value.enabled
      timeout = lookup(termination_notification.value, "timeout", null)
    }
  }
  user_data                    = var.user_data
  vtpm_enabled                 = var.vtpm_enabled
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  zone                         = var.zone
  lifecycle {
    ignore_changes = [
      tags["create_date"], identity
    ]
  }
}

resource "azurerm_managed_disk" "disk" {
  #for_each               = var.data_disks
  for_each               = var.data_disks != null ? { for k, v in var.data_disks : k => v if v != null } : {}
  name                   = each.value.name
  resource_group_name    = lookup(each.value, "resource_group_name", null) == null ? var.resource_group_name : lookup(each.value, "resource_group_name", null)
  location               = lookup(each.value, "location", null) == null ? var.location : lookup(each.value, "location", null)
  storage_account_type   = each.value.storage_account_type
  create_option          = lookup(each.value, "create_option", "Empty")
  disk_encryption_set_id = lookup(each.value, "disk_encryption_set_id", null)
  disk_iops_read_write   = lookup(each.value, "disk_iops_read_write", null)
  disk_mbps_read_write   = lookup(each.value, "disk_mbps_read_write", null)
  disk_iops_read_only    = lookup(each.value, "disk_iops_read_only", null)
  disk_mbps_read_only    = lookup(each.value, "disk_mbps_read_only", null)
  upload_size_bytes      = lookup(each.value, "upload_size_bytes", null)
  disk_size_gb           = lookup(each.value, "disk_size_gb", null)
  edge_zone              = lookup(each.value, "edge_zone", null)
  dynamic "encryption_settings" {
    for_each = each.value.encryption_settings != null ? [each.value.encryption_settings] : []
    content {
      dynamic "disk_encryption_key" {
        for_each = encryption_settings.value.disk_encryption_key != null ? [encryption_settings.value.disk_encryption_key] : []
        content {
          secret_url      = disk_encryption_key.value.secret_url
          source_vault_id = disk_encryption_key.value.source_vault_id
        }
      }
      dynamic "key_encryption_key" {
        for_each = encryption_settings.value.key_encryption_key != null ? [encryption_settings.value.key_encryption_key] : []
        content {
          key_url         = key_encryption_key.value.key_url
          source_vault_id = key_encryption_key.value.source_vault_id
        }
      }
    }
  }
  hyper_v_generation                = lookup(each.value, "hyper_v_generation", null)
  image_reference_id                = lookup(each.value, "image_reference_id", null)
  gallery_image_reference_id        = lookup(each.value, "gallery_image_reference_id", null)
  logical_sector_size               = lookup(each.value, "disk_size", null)
  optimized_frequent_attach_enabled = lookup(each.value, "optimized_frequent_attach_enabled", false)
  performance_plus_enabled          = lookup(each.value, "performance_plus_enabled", false)
  os_type                           = lookup(each.value, "os_type", null)
  source_resource_id                = lookup(each.value, "source_resource_id", null)
  source_uri                        = lookup(each.value, "source_uri", null)
  storage_account_id                = lookup(each.value, "storage_account_id", null)
  tier                              = lookup(each.value, "tier", null)
  max_shares                        = lookup(each.value, "max_shares", null)
  trusted_launch_enabled            = lookup(each.value, "trusted_launch_enabled", null)
  security_type                     = lookup(each.value, "security_type", null)
  secure_vm_disk_encryption_set_id  = lookup(each.value, "secure_vm_disk_encryption_set_id", null)
  on_demand_bursting_enabled        = lookup(each.value, "on_demand_bursting_enabled", null)
  tags                              = local.tags_disk
  zone                              = each.value.zone
  network_access_policy             = lookup(each.value, "network_access_policy", null)
  disk_access_id                    = lookup(each.value, "disk_access_id", null)
  public_network_access_enabled     = lookup(each.value, "public_network_access_enabled", true)
  lifecycle {
    ignore_changes = [
      tags["create_date"]
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  for_each                  = var.data_disks != null ? { for k, v in var.data_disks : k => v if v != null } : {}
  managed_disk_id           = azurerm_managed_disk.disk[each.key].id
  virtual_machine_id        = azurerm_linux_virtual_machine.vm.id
  lun                       = each.value.lun
  caching                   = each.value.caching
  write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", false)
}