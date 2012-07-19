class munin::plugins::setup {

  # This is required for the munin-node service and package requirements below.
  include munin::client

  file {
    [ '/etc/munin/plugins', '/etc/munin/plugin-conf.d' ]:
      source => "puppet:///modules/common/empty",
      ignore => [ '.ignore', 'snmp_*' ],
      ensure => directory, checksum => mtime,
      recurse => true, purge => true, force => true,
      mode => 0755, owner => root, group => 0,
      notify => Service['munin-node'];
    '/etc/munin/plugin-conf.d/munin-node':
      ensure => present,
      mode => 0644, owner => root, group => 0,
      notify => Service['munin-node'],
  }
  case $kernel {
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
