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
        'absent' => hiera('munin_port','4949'),
        default => $port
    }

    $hiera_munin_host = hiera('munin_host','')
    $munin_host_real = $host ? {
        'absent' =>  $hiera_munin_host ? {
                        '' => $::fqdn,
                        'fqdn' => $::fqdn,
                        default => $hiera_munin_host
                    },
        default => $host
    }

    @@concat::fragment{ "munin_client_${fhost}_${munin_port_real}":
        target => '/etc/munin/munin.conf',
        content => template("munin/client.erb"),
        tag => 'munin',
    }
}
