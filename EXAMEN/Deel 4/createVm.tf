provider "vsphere" {
  user = var.user
  password = var.vsphere_pass
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "StudentDatacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "coudron-lukas"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "StudentCluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "webserver-template" {
  name          = "ubuntu-template-examen"
  datacenter_id = data.vsphere_datacenter.dc.id
}


#UBUNTU VM
resource "vsphere_virtual_machine" "vm" {
  count = 1
  name             = "borat-ubu"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 2048
  guest_id = data.vsphere_virtual_machine.webserver-template.guest_id

  scsi_type = data.vsphere_virtual_machine.webserver-template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.webserver-template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.webserver-template.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.webserver-template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.webserver-template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.webserver-template.id

    customize {
      linux_options {
        host_name = "borat-ubu"
        domain    = "lab.local"
      }

      network_interface {
        ipv4_address = "192.168.50.10${count.index}"
        ipv4_netmask = 24
      }

      ipv4_gateway = "192.168.50.1"
      dns_server_list = ["192.168.40.1" , "172.23.82.60"]
    }
  }
}



data "vsphere_virtual_machine" "webserver-template-windows" {
  name          = "win-template"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#WINDOWS VM
resource "vsphere_virtual_machine" "vmc" {
  firmware         = "efi"
  name             = "borat-win"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 1
  memory   = 1024
  guest_id = data.vsphere_virtual_machine.webserver-template-windows.guest_id

  scsi_type = data.vsphere_virtual_machine.webserver-template-windows.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.webserver-template-windows.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.webserver-template-windows.disks[0].size
    eagerly_scrub    = data.vsphere_virtual_machine.webserver-template-windows.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.webserver-template-windows.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.webserver-template-windows.id

    customize {
      windows_options {
        computer_name = "borat-win"
        #domain    = "lab.local"
      }

      network_interface {
        ipv4_address = "192.168.50.110"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "192.168.50.1"
      dns_server_list = ["172.20.0.2", "172.20.0.3"]
    }
  }
}

#module "example-server-windowsvm-withdatadisk" {
#  source            = "Terraform-VMWare-Modules/vm3nic/vsphere"
#  version           = "0.1.0"
#  vmtemp            = "win-template"
#  instances         = 1
#  vmname            = "borat-win"
#  vmrp              = data.vsphere_compute_cluster.cluster.resource_pool_id
#  net01              = "VM Network"
#  is_windows_image  = "true"
#  dc                = "StudentDatacenter"
#  ds_cluster        = data.vsphere_datastore.datastore.id
#  winadminpass      = "P@ssw0rd" //Optional
#}