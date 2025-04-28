variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "network_interface" {
  type = list(object({
    ip_configuration = list(object({
      name                                               = string
      gateway_load_balancer_frontend_ip_configuration_id = optional(string)
      subnet_id                                          = optional(string)
      private_ip_address_version                         = optional(string)
      private_ip_address_allocation                      = string
      public_ip_address_id                               = optional(string)
      primary                                            = optional(bool)
      private_ip_address                                 = optional(string)
    }))
    location                       = optional(string)
    name                           = optional(string)
    resource_group_name            = optional(string)
    auxiliary_mode                 = optional(string)
    auxiliary_sku                  = optional(string)
    dns_servers                    = optional(list(string))
    edge_zone                      = optional(string)
    ip_forwarding_enabled          = optional(bool)
    accelerated_networking_enabled = optional(bool)
    internal_dns_name_label        = optional(string)
    tags                           = optional(map(string))
  }))
}

variable "admin_username" {
  type      = string
  default   = "operacao"
  sensitive = true
}

variable "license_type" {
  type    = string
  default = null
}

variable "name" {
  type = string
}

variable "network_interface_ids" {
  type    = list(string)
  default = null
}

variable "os_disk" {
  type = object({
    caching              = string
    storage_account_type = string
    diff_disk_settings = optional(object({
      optional  = string
      placement = optional(string)
    }))
    disk_encryption_set_id           = optional(string)
    disk_size_gb                     = optional(number)
    name                             = optional(string)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
    write_accelerator_enabled        = optional(bool)
  })
}

variable "size" {
  type = string
}


variable "additional_capabilities" {
  type = object({
    ultra_ssd_enabled = optional(bool)
    # check the default
    #hibernation_enabled = optional(bool)
  })
  default = null
}

variable "admin_password" {
  type      = string
  sensitive = true
  validation {
    condition = (length(var.admin_password) >= 8 &&
      can(length((regex("[[:lower:]]+", var.admin_password)))) == true &&
      can(length(regex("[0-9]+", var.admin_password))) == true &&
      can(length(regex("[[:punct:]]+", var.admin_password))) == true
    )
    error_message = "A senha não atende os requisitos mínimos."
  }
}

variable "admin_ssh_key" {
  type = list(object({
    public_key = string
    username   = string
  }))
  default = null
}

variable "allow_extension_operations" {
  type    = bool
  default = true
}

variable "availability_set_id" {
  type    = string
  default = null
}

variable "boot_diagnostics" {
  type = object({
    storage_account_uri = optional(string)
  })
  default = null
}

variable "bypass_platform_safety_checks_on_user_schedule_enabled" {
  type    = bool
  default = false
}

variable "capacity_reservation_group_id" {
  type    = string
  default = null
}

variable "computer_name" {
  type    = string
  default = null
}

variable "custom_data" {
  type    = string
  default = null
}

variable "dedicated_host_id" {
  type    = string
  default = null
}

variable "dedicated_host_group_id" {
  type    = string
  default = null
}

variable "disable_password_authentication" {
  type    = bool
  default = true
}

variable "disk_controller_type" {
  type    = string
  default = null
}

variable "edge_zone" {
  type    = string
  default = null
}

variable "encryption_at_host_enabled" {
  type    = bool
  default = false
}

variable "eviction_policy" {
  type    = string
  default = null
}

variable "extensions_time_budget" {
  type    = string
  default = "PT1H30M"
}

variable "gallery_application" {
  type = list(object({
    version_id                                  = string
    automatic_upgrade_enabled                   = optional(bool)
    configuration_blob_uri                      = optional(string)
    order                                       = optional(number)
    tag                                         = optional(string)
    treat_failure_as_deployment_failure_enabled = optional(bool)
  }))
  default = null
}

variable "identity" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Container Registry"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "SystemAssigned"
  }
}

variable "patch_assessment_mode" {
  type    = string
  default = "ImageDefault"
}

variable "patch_mode" {
  type    = string
  default = "ImageDefault"
}

variable "max_bid_price" {
  type    = number
  default = -1
}

variable "plan" {
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

variable "platform_fault_domain" {
  type    = number
  default = null
}

variable "priority" {
  type    = string
  default = "Regular"
}

variable "provision_vm_agent" {
  type    = bool
  default = true
}

variable "proximity_placement_group_id" {
  type    = string
  default = null
}

variable "reboot_setting" {
  type    = string
  default = null
}

variable "secret" {
  type = list(object({
    certificate = list(object({
      url = string
    }))
    key_vault_id = string
  }))
  default = null
}

variable "secure_boot_enabled" {
  type    = bool
  default = false
}

variable "source_image_id" {
  type    = string
  default = null
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "os_image_notification" {
  type = object({
    timeout = optional(string)
  })
  default = null
}

variable "termination_notification" {
  type = object({
    enabled = bool
    timeout = optional(string)
  })
  default = null
}

variable "user_data" {
  type    = string
  default = null
}

variable "vm_agent_platform_updates_enabled" {
  type    = bool
  default = false
}

variable "vtpm_enabled" {
  type    = bool
  default = false
}

variable "virtual_machine_scale_set_id" {
  type    = string
  default = null
}

variable "zone" {
  type = number
}

variable "data_disks" {
  type = list(object({
    name                   = string
    resource_group_name    = optional(string)
    location               = optional(string)
    storage_account_type   = string
    create_option          = string
    disk_encryption_set_id = optional(string)
    disk_iops_read_write   = optional(number)
    disk_mbps_read_write   = optional(number)
    disk_iops_read_only    = optional(number)
    disk_mbps_read_only    = optional(number)
    upload_size_bytes      = optional(number)
    disk_size_gb           = optional(number)
    edge_zone              = optional(string)
    encryption_settings = optional(object({
      disk_encryption_key = optional(object({
        secret_url      = string
        source_vault_id = optional(string)
      }))
      key_encryption_key = optional(object({
        key_url          = string
        source_vault_id2 = optional(string)
      }))
    }))
    hyper_v_generation                = optional(string)
    image_reference_id                = optional(string)
    gallery_image_reference_id        = optional(string)
    logical_sector_size               = optional(number)
    optimized_frequent_attach_enabled = optional(bool)
    performance_plus_enabled          = optional(bool)
    os_type                           = optional(string)
    source_resource_id                = optional(string)
    source_uri                        = optional(string)
    storage_account_id                = optional(string)
    tier                              = optional(string)
    max_shares                        = optional(number)
    trusted_launch_enabled            = optional(bool)
    security_type                     = optional(string)
    secure_vm_disk_encryption_set_id  = optional(string)
    on_demand_bursting_enabled        = optional(bool)
    tags                              = optional(map(string))
    zone                              = optional(string)
    network_access_policy             = optional(string)
    disk_access_id                    = optional(string)
    public_network_access_enabled     = optional(bool)
    lun                               = optional(number)
    caching                           = optional(string)
    write_accelerator_enabled         = optional(bool)
  }))
  default = null
}