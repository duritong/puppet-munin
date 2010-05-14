define munin::register::snmp (
  $community = 'public',
  $description = 'absent'
)
{
    $fhost = $name
    $munin_host_real = $fqdn
    $client_type = 'snmp'
    $config = [ 'use_node_name no' ]

    exec { "munin_register_snmp_${fhost}":
        command => "munin-node-configure --snmp ${fhost} --snmpcommunity ${community} | sh",
        unless => "ls /etc/munin/plugins/snmp_${fhost}_* &> /dev/null",
    }

    @@file { "munin_snmp_${fhost}":
        ensure => present,
        path => "/var/lib/puppet/modules/munin/nodes/${fhost}",
        content => template("munin/client.erb"),
        tag => 'munin',
    }
}
