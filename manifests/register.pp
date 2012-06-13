define munin::register (
  $host = $::fqdn,
  $port = '4949',
  $description = 'absent',
  $config = []
)
{
  $fhost = $name
  $client_type = 'client'

  @@concat::fragment{ "munin_client_${fhost}_${munin_port_real}":
    target => '/etc/munin/munin.conf',
    content => template("munin/client.erb"),
    tag => 'munin',
  }
}
