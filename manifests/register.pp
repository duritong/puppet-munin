# register a client
define munin::register(
  $host         = $::fqdn,
  $port         = '4949',
  $use_ssh      = false,
  $description  = 'absent',
  $config       = [],
  $group        = 'absent',
){
  $fhost = $name
  $client_type = 'client'
  @@file{
    "/etc/munin/conf.d/10_${fhost}_${port}.conf":
      content => template('munin/client.erb'),
      owner   => root,
      group   => 0,
      mode    => 0644,
      tag     => 'munin_client_register'
  }
}
