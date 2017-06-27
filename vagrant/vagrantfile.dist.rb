require_relative 'vagrant_vars.rb'
require 'ipaddr'
require 'openssl'
include VagrantVars

unless Vagrant.has_plugin?('vagrant-vbguest')
  raise 'vagrant-vbguest plugin is not installed'
end

unless Vagrant.has_plugin?('vagrant-hostsupdater')
  raise 'vagrant-hostsupdater plugin not installed and is required'
end

Vagrant.configure('2') do |config|

  if ARGV[1] and \
      (ARGV[1].split('=')[0] == '--provider' or ARGV[2])
    provider = (ARGV[1].split('=')[1] || ARGV[2])
  else
    provider = (ENV['VAGRANT_DEFAULT_PROVIDER'] || :virtualbox).to_sym
  end

  config.vm.provision 'lamp', type: RbConfig::CONFIG['host_os'] =~ /w32/ ? :ansible_local : :ansible do |lamp|
    lamp.playbook = 'dev/ansible/lamp/playbook.yml'
    lamp.limit = 'all'
  end

  config.vm.provision 'setup', type: RbConfig::CONFIG['host_os'] =~ /w32/ ? :ansible_local : :ansible, run: 'always' do |setup|
    setup.playbook = 'dev/ansible/setup/playbook.yml'
    setup.limit = 'all'
  end

  if provider == 'aws'
    config.vm.box = 'dimroc/awsdummy'

    config.vm.provider :aws do |aws, override|    
      aws.access_key_id = AWS_ACCESS_KEY_ID
      aws.secret_access_key = AWS_ACCESS_KEY_SECRET
      aws.keypair_name = AWS_KEYPAIR_NAME
      aws.region = AWS_REGION
      aws.instance_type = AWS_INSTANCE_TYPE
      aws.associate_public_ip = true
      aws.subnet_id = AWS_SUBNET_ID
      aws.ami = 'ami-5189a661'

      aws.tags = AWS_TAGS

      aws.block_device_mapping = [
        { 
          'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 8
        }
      ]

      override.ssh.username = 'ubuntu'
      override.ssh.private_key_path = './' + AWS_KEYPAIR_NAME + '.pem'
    end
  else
  
    config.vm.provider :virtualbox or config.vm.provider :vmware_fusion do |v|
        config.vm.box = $vm_box

        config.ssh.forward_agent = true

        config.vm.synced_folder '.', '/vagrant', id: 'v-root', mount_options: %w(rw tcp nolock noacl async v3), type: 'nfs', nfs_udp: false
        config.vm.synced_folder Dir.home + '/.ssh', '/home/vagrant/host_ssh', mount_options: %w(rw tcp nolock noacl async v3), type: 'nfs', nfs_udp: false

      config.vm.provider :virtualbox do |virtualbox|
        virtualbox.customize ['modifyvm', :id, '--memory', $amount_of_ram]
        virtualbox.customize ['modifyvm', :id, '--cpus', $number_of_cpus]
        virtualbox.customize ['modifyvm', :id, '--cpuexecutioncap', '100']
        virtualbox.customize ['modifyvm', :id, '--hwvirtex', 'on']
      end

      config.vm.provider :vmware_fusion or config.vm.provider :vmware_workstation do |vmware|
        vmware.vmx['memsize']  = $amount_of_ram
        vmware.vmx['numvcpus'] = $number_of_cpus
      end
    end
  end
  
  #################################################
  ####                Machines                 ####
  #################################################

  config.vm.define 'dev', primary: true do |dev|
    dev.vm.network :private_network, ip: $ip_address
    config.vm.network :forwarded_port, guest: 80, host: 4567, auto_correct: true
    config.vm.network :forwarded_port, guest: 443, host: 5678, auto_correct: true
    dev.vm.hostname = $dev_host_name

    dev.vm.provider :virtualbox do |v|
      v.name = $dev_host_name + ' - Dev'
    end

    dev.vm.provision 'lamp', type: RbConfig::CONFIG['host_os'] =~ /w32/ ? :ansible_local : :ansible do |lamp|
      ipArray = $ip_address.split('.');
      ipArray[-1] = '1';

      lamp.extra_vars = {
        enviroment: 'dev',
        server_name: $dev_host_name,
        provider: 'local',
        database_name: $database_name,
        database_user: $database_user,
        database_password: $database_password,
        xdebug_ip: ipArray.join('.'),
      };
    end

    config.vm.provision :shell, run: 'always',
        :inline => 'sudo -i -u vagrant cp -R /home/vagrant/host_ssh/* /home/vagrant/.ssh/ && chmod -R 700 /home/vagrant/.ssh/*'

    dev.vm.provision 'setup', type: RbConfig::CONFIG['host_os'] =~ /w32/ ? :ansible_local : :ansible do |setup|
      setup.extra_vars = {
        enviroment: 'dev'
      }
    end
  end
  
end
