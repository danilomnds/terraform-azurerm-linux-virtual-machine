# Module - Linux Virtual Machines
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the creation of Linux Virtual Machines.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.11.3           | 4.26.0          |

## Specifying a version

To avoid that your code get updates automatically, is mandatory to set the version using the `source` option. 
By defining the `?ref=***` in the the URL, you can define the version of the module.

Note: The `?ref=***` refers a tag on the git module repo.

## Default use case

```hcl
module "lnx0001" {
  source    = "git::https://github.com/danilomnds/terraform-azurerm-linux-virtual-machine?ref=v1.0.0"
  location = "Brazil South"
  resource_group_name = "<resource group>"
  name = "lnx0001"
  admin_username = var.linux_username
  admin_password = var.linux_password
  # You can customize the caching (default ReadWrite) and the name of the boot disk.  
  os_disk = {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
    disk_size_gb = 64
    # the default is vmname_boot_disk
    # name = "custom name"
  }
  size = "Standard_D2s_v5"
  zone = "1" 
  # You can customize using the parameters publisher, offer, sku and version
  source_image_reference = {
      publisher = "RedHat"
      offer = "RHEL"
      sku = "9.4"
      version = "latest"
  }
  # if you want to attach an existing NIC
  # network_interface_ids = []
  # set a custom storage account for the boot diagnostics 
  boot_diagnostics = {
    storage_account_uri = "https://<storage account>.blob.core.windows.net/"
  } 
  ultra_ssd_enabled = false
  # optional. It would be used when you are deploying an appliance from the market place.
  /* 
  plan = {
    name = 
    product = 
    publisher = 
  }
  */
  network_interface = [
    {
      ip_configuration = [
      { name = "nic1ip1"
        subnet_id = <subnet id>
        accelerated_networking_enabled = "true"
        private_ip_address_allocation = "Static"
        primary = true
        private_ip_address = "static ip 1"
      },
      # if you neeed two IPs
      { name = "nic1ip2"
        subnet_id = <subnet id>
        accelerated_networking_enabled = "true"
        private_ip_address_allocation = "Static"
        primary = false
        private_ip_address = "static ip 1"
      }
      ]
    },
    # If you need a secondary nic 
    {
      ip_configuration = [
      { name = "nic2ip1"
        subnet_id = <subnet id>
        enable_accelerated_networking = "true"
        private_ip_address_allocation = "Static"
        primary = false
        private_ip_address = "static ip 1"
      },
      # if you neeed two IPs
      { name = "nic2ip2"
        subnet_id = <subnet id>
        enable_accelerated_networking = "true"
        private_ip_address_allocation = "Static"
        primary = false
        private_ip_address = "static ip 1"
      }
      ]
    }  
  ]  
  data_disks = [
    { name = <vmname>_data_disk_01
      storage_account_type = "Standard_LRS"
      create_option = "Empty"
      disk_size_gb = "100"
      lun = "0"
      caching = "None"
      zones = "1"
    },
    {
      name = <vmname>_data_disk_02
      storage_account_type = "Standard_LRS"
      create_option = "Empty"
      disk_size_gb = "100"
      lun = "0"
      caching = "None"
      zones = 1
    }
  ]
  tags = {
    department      = ""
    area            = ""
    project         = ""
    system          = ""
    dl_owner        = ""
    environment     = ""
    layer           = ""
  }  
}
output "vm_name" {
  value = module.lnx0001.vm_name
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin_username | the username of the local administrator used for the Virtual Machine | `string` | n/a | `Yes` |
| location | The Azure location where the Linux Virtual Machine should exist | `string` | n/a | `Yes` |
| license_type | Specifies the License Type for this Virtual Machine | `string` | n/a | No |
| name | The name of the Linux Virtual Machine | `string` | n/a | `Yes` |
| network_interface_ids | A list of Network Interface IDs which should be attached to this Virtual Machine | `list(string)` | n/a | No |
| os_disk | A os_disk block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | n/a | `Yes` |
| resource_group_name | The name of the Resource Group in which the Linux Virtual Machine should be exist | `string` | n/a | `Yes` |
| size | The SKU which should be used for this Virtual Machine, such as Standard_F2 | `string` | n/a | `Yes` |
| os_disk | A additional_capabilities block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | n/a | No |
| admin_password | The Password which should be used for the local-administrator on this Virtual Machine | `string` | n/a | No |
| admin_ssh_key | One or more admin_ssh_key blocks as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `list(object({}))` | n/a | No |
| allow_extension_operations | Should Extension Operations be allowed on this Virtual Machine | `bool` | `true` | No |
| availability_set_id | Specifies the ID of the Availability Set in which the Virtual Machine should exist | `string` | n/a | No |
| boot_diagnostics | A boot_diagnostics block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | n/a | No |
| bypass_platform_safety_checks_on_user_schedule_enabled | Specifies whether to skip platform scheduled patching when a user schedule is associated with the VM | `bool` | `false` | No |
| capacity_reservation_group_id | Specifies the ID of the Capacity Reservation Group which the Virtual Machine should be allocated to | `string` | n/a | No |
| computer_name | Specifies the Hostname which should be used for this Virtual Machine | `string` | n/a | No |
| custom_data | The Base64-Encoded Custom Data which should be used for this Virtual Machine | `string` | n/a | No |
| dedicated_host_id | The ID of a Dedicated Host where this machine should be run on | `string` | n/a | No |
| dedicated_host_group_id | The ID of a Dedicated Host Group that this Linux Virtual Machine should be run within | `string` | n/a | No |
| disable_password_authentication | Should Password Authentication be disabled on this Virtual Machine | `bool` | `true` | No |
| disk_controller_type | Specifies the Disk Controller Type used for this Virtual Machine | `string` | n/a | No |
| edge_zone | Specifies the Edge Zone within the Azure Region where this Linux Virtual Machine should exist | `string` | n/a | No |
| encryption_at_host_enabled | Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host | `bool` | `false` | No |
| eviction_policy | Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance | `string` | n/a | No |
| extensions_time_budget | Specifies the duration allocated for all extensions to start | `string` | `PT1H30M` | No |
| gallery_application | One or more gallery_application blocks as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)  | `list(object({}))` | null | No |
| identity | An identity block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | `type = "SystemAssigned"` | No |
| patch_assessment_mode | Specifies the mode of VM Guest Patching for the Virtual Machine | `string` | `ImageDefault` | No |
| patch_mode | Specifies the mode of in-guest patching to this Linux Virtual Machine | `string` | `ImageDefault` | No |
| max_bid_price | The maximum price you're willing to pay for this Virtual Machine, in US Dollars | `number` | `-1` | No |
| plan | A plan block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | n/a | No |
| platform_fault_domain | Specifies the Platform Fault Domain in which this Linux Virtual Machine should be created | `number` | `-1` | No |
| priority | Specifies the priority of this Virtual Machine | `string` | `Regular` | No |
| provision_vm_agent | Should the Azure VM Agent be provisioned on this Virtual Machine | `bool` | `true` | No |
| proximity_placement_group_id | The ID of the Proximity Placement Group which the Virtual Machine should be assigned to | `string` | n/a | No |
| reboot_setting | Specifies the reboot setting for platform scheduled patching | `string` | n/a | No |
| secret | One or more secret blocks as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `list(object({}))` | n/a | No |
| secure_boot_enabled | Specifies whether secure boot should be enabled on the virtual machine | `bool` | `false` | No |
| source_image_id | The ID of the Image which this Virtual Machine should be created from | `string` | n/a | No |
| source_image_reference | A source_image_reference block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | n/a | No |
| tags | A mapping of tags which should be assigned to this Virtual Machine | `object({})` | n/a | No |
| os_image_notification | A os_image_notification block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | n/a | No |
| termination_notification | A termination_notification block as defined in the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | `object({})` | n/a | No |
| user_data | The Base64-Encoded User Data which should be used for this Virtual Machine | `string` | n/a | No |
| vm_agent_platform_updates_enabled | Specifies whether VMAgent Platform Updates is enabled | 
`bool` | `false` | No |
| vtpm_enabled | Specifies whether vTPM should be enabled on the virtual machine | `bool` | `false` | No |
| virtual_machine_scale_set_id | Specifies the Orchestrated Virtual Machine Scale Set that this Virtual Machine should be created within | `string` | n/a | No |
| zone | Specifies the Availability Zones in which this Linux Virtual Machine should be located | `number` | n/a | No |
| network_interface | One or more nics can be created using this module. Check the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) for a full list of available parameters | `list(object({}))` | n/a | No |
| data_disks | One or more disks can be created using this module. Check the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) for a full list of available parameters | `list(object({}))` | n/a | No |

## Output variables

| Name | Description |
|------|-------------|
| vm_name | vm name |
| nics | nics |
| data_disks | data disks |
| vm_public_ip | public IPs associated to the VM |
| vm_private_ip | private IPs associated to the VM |


## Tips

Commands to get information of appliances available on azure market place.
- 1º List information about a publisher. <br>
- 2º List information about an specific image of a publisher. <br>
- 3º Accept the terms of use. <br>

```az cli
az vm image list --all --publisher ibm -o table
az vm image show --offer ibm-security-guardium-multi-cloud --publisher ibm --sku ibm-security-guardium-collector --version 11.3.0
az vm image terms accept --urn ibm:ibm-security-guardium-multi-cloud:ibm-security-guardium-collector:11.3.0 --subscription ""
```

## Documentation

Terraform Network Interfaces: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)<br>
Terraform Linux Virtual Machines: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)<br>
Terraform Managed Disks: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)
Terraform Disk Attachment: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment)