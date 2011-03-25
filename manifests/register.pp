define munin::register (
  $host = 'absent',
  $port = 'absent',
  $description = 'absent',
  $config = []
)
{
    $fhost = $name
    $client_type = 'client'

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

    @@file { "munin_client_${fhost}_${munin_port_real}":
        ensure => present,
        path => "/var/lib/puppet/modules/munin/nodes/${fhost}_${munin_port_real}",
        content => template("munin/client.erb"),
        tag => 'munin',
    }
}
