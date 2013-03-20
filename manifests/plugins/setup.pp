class munin::plugins::setup {

  # This is required for the munin-node service and package requirements below.
  include munin::client

  file {
    [ '/etc/munin/plugins', '/etc/munin/plugin-conf.d' ]:
      ignore    => 'snmp_*',
      ensure    => directory,
      checksum  => mtime,
      recurse 	=> true,
      purge     => true,
      force     => true,
      notify    => Service['munin-node'],
      owner     => root,
      group     => 0,
      mode      => '0755';
    '/etc/munin/plugin-conf.d/munin-node':
      ensure    => present,
      notify    => Service['munin-node'],
      owner     => root,
      group     => 0,
      mode      => '0640';
  }
  case $::kernel {
    openbsd: {
      File['/etc/munin/plugin-conf.d/munin-node']{
        before => File['/var/run/munin'],
      }
    }
    default: {
      File['/etc/munin/plugin-conf.d/munin-node']{
        before => Package['munin-node'],
      }
    }
  }
}
