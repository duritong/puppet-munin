# register a client
define munin::register (
  $host         = $facts['networking']['fqdn'],
  $port         = '4949',
  $use_ssh      = false,
  $description  = 'absent',
  $config       = [],
  $group        = 'absent',
) {
  $fhost = $name
  $client_type = 'client'
  if $host =~ Stdlib::IP::Address::V6::Nosubnet {
    $host_str = "[${host}]"
  } else {
    $host_str = $host
  }
  @@file {
    "/etc/munin/munin-conf.d/10_${fhost}_${port}.conf":
      content => template('munin/client.erb'),
      owner   => root,
      group   => 0,
      mode    => '0644',
      tag     => 'munin_client_register',
  }
}
