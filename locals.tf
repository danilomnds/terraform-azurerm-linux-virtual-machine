locals {
  default_tags = {
    deployedby  = "Terraform"
    provider    = "azr"
    region      = replace(lower(var.location), " ", "")
    create_date = formatdate("DD/MM/YY hh:mm", timeadd(timestamp(), "-3h"))
  }
  type_vm = {
    type     = "iaas"
    resource = "compute"
  }
  type_disk = {
    type     = "iaas"
    resource = "storage"
  }
  type_net = {
    type     = "iaas"
    resource = "network"
  }
  tags_vm   = merge(local.default_tags, local.type_vm, var.tags)
  tags_disk = merge(local.default_tags, local.type_disk, var.tags)
  tags_net  = merge(local.default_tags, local.type_net, var.tags)
}