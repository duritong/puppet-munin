define munin::register(
  $host = 'absent',
  $port = 'absent'
)
{
    $munin_port_real = $port ? {
    'absent' => $munin_port ? {
                  '' => 4949,
                  default => $munin_port
                },
    default => $port
  }

    $munin_host_real = $host ? {
    'absent' => $munin_host ? {
                  '' => $fqdn,
                  'fqdn' => $fqdn,
                  default => $munin_host
                },
    default => $host
    }

    @@file { "/var/lib/puppet/modules/munin/nodes/${name}_${munin_port_real}":
        ensure => present,
        content => template("munin/defaultclient.erb"),
        tag => 'munin',
    }
}


