module VagrantVars
    $dev_host_name = 'placeholder.dev'
    $ip_address = '192.168.33.165' #IP address for the dev server. It is important that this does not conflict with the IP address range of your local network
    $vm_box = 'bento/ubuntu-16.04'

    $number_of_cpus = 1 #The number of CPUS to virtualize
    $amount_of_ram = 2048 #The amount of ram to provide the virtual machine

    # Ansible vars below
    $database_user = 'root' #user to use the database as
    $database_password = 'password' #password for the database user
    $database_name = 'database' #database name
end