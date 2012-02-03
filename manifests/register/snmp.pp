define munin::register::snmp (
  $community = 'public',
  $description = 'absent',
  $port = 'absent'
)
{
    $fhost = $name
    $munin_host_real = $::fqdn
    $client_type = 'snmp'
    $config = [ 'use_node_name no' ]

    $munin_port_real = $port ? {
      'absent' => hiera('munin_port','4949'),
      default => $port
    }

    exec { "munin_register_snmp_${fhost}":
        command => "munin-node-configure --snmp ${fhost} --snmpcommunity ${community} --shell | sh",
        unless => "ls /etc/munin/plugins/snmp_${fhost}_* &> /dev/null",
    }

    @@concat::fragment{ "munin_snmp_${fhost}":
        target => '/etc/munin/munin.conf',
        content => template("munin/client.erb"),
        tag => 'munin',
    }
}
