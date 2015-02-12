require 'yaml'

VAGRANTFILE_API_VERSION = "2"
CONFIG_FILE_NAME = ENV["VAGRANT_CLOUD_CONFIG"] || File.dirname(__FILE__) + '/default_config.yml'
CFG = YAML.load(File.read(CONFIG_FILE_NAME))
MASTER_HOSTNAME = "master"
CLIENT_HOSTNAME = "client"

Vagrant.require_version ">= 1.6.2"


# === helper functions ===

def generate_hosts_file()
  hosts_lines = [
    "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4",
    "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6",
    "#{CFG["master_ip"]} #{MASTER_HOSTNAME}.#{CFG["dns_domain"]} #{MASTER_HOSTNAME}",
  ]
  CFG["client_ips"].each.with_index do |client_ip, client_idx|
    hosts_lines << "#{client_ip} #{CLIENT_HOSTNAME}#{client_idx}.#{CFG["dns_domain"]} #{CLIENT_HOSTNAME}#{client_idx}"
  end

  hosts_lines.join("\n") + "\n"  # make sure the file ends with a newline
end


# === Vagrant config ===

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # the dir on the VM has to be '/vagrant' to override the default NFS sync
  config.vm.synced_folder './share', '/vagrant', type: 'rsync'

  config.vm.provider :libvirt do |libvirt, override|
    libvirt.driver = 'kvm'
    libvirt.connect_via_ssh = false
    libvirt.username = 'root'
    libvirt.storage_pool_name = CFG["libvirt"]["storage_pool_name"]
    libvirt.default_prefix = CFG["libvirt"]["default_prefix"]
    libvirt.default_network = CFG["libvirt"]["default_network"]
    # libvirt.default_network = 'default'
    # leave out to connect directly with qemu:///system
    # libvirt.host = 'localhost'

    override.vm.box = CFG["libvirt"]["box"]
    override.vm.box_url = CFG["libvirt"]["box_url"]
  end

  # Cloud master
  config.vm.define "master" do |vm_config|
    vm_config.vm.provision "shell", inline: "echo '#{generate_hosts_file}' > /etc/hosts"
    vm_config.vm.provision "shell", inline: "/vagrant/preconfigure_master.sh"
    vm_config.vm.network "private_network", ip: CFG["master_ip"], libvirt__dhcp_enabled: false, libvirt__network_name: CFG["libvirt"]["private_net_0"]
    vm_config.vm.hostname = MASTER_HOSTNAME

    vm_config.vm.synced_folder './share-master', '/vagrant-master', type: 'rsync'

    vm_config.vm.provider :libvirt do |libvirt|
      libvirt.memory = 3072
    end
  end

  # Cloud clients
  CFG["client_ips"].each.with_index do |client_ip, client_idx|
    config.vm.define "client#{client_idx}" do |vm_config|
      vm_config.vm.provision "shell", inline: "echo '#{generate_hosts_file}' > /etc/hosts"
      vm_config.vm.provision "shell", inline: "/vagrant/preconfigure_client.sh"
      vm_config.vm.network "private_network", ip: client_ip, libvirt__dhcp_enabled: false, libvirt__network_name: CFG["libvirt"]["private_net_0"]
      vm_config.vm.hostname = "#{CLIENT_HOSTNAME}#{client_idx}"

      vm_config.vm.provider :libvirt do |libvirt|
        libvirt.memory = 2048
      end
    end
  end

end
