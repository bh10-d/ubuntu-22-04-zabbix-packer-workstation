source "vmware-iso" "jammy-daily" {
  // Docs: https://www.packer.io/plugins/builders/vmware/iso

  // VM Info:
  vm_name       = "jammy-2022-04-20"
  guest_os_type = "ubuntu64Guest"
  version       = "16"
  headless      = false
  // Virtual Hardware Specs
  memory        = 4096
  cpus          = 2
  cores         = 3
  disk_size     = 30000
  sound         = true
  disk_type_id  = 0
  
  // ISO Details
  iso_urls     = ["https://old-releases.ubuntu.com/releases/jammy/ubuntu-22.04-live-server-amd64.iso"]
  // iso_checksum = "sha256:c02a89385c11ae5856b5c0b68b37aa838ae848659e89a302a687251ea004ee4f"
  iso_checksum = "sha256:84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
  output_directory  = "/hoctap/TTDN/Evvo/Real_Scenario/Ubuntu-22.04-Build"
  http_directory    = "http"
  ssh_username      = "vmadmin"
  ssh_password      = "MyP@ssw0rd-22!"
  shutdown_command  = "sudo -S shutdown -P now"
  ssh_timeout = "600s"
  boot_wait = "5s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
}

build {
  sources = ["sources.vmware-iso.jammy-daily"]
  provisioner "shell" {
    execute_command = "echo 'vmadmin' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    script = "./provisioners/install-zabbix.sh"
  }
}