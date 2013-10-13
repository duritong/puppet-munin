# Set up the munin plugins for a node
class munin::plugins::setup {

  file {
    [ '/etc/munin/plugins', '/etc/munin/plugin-conf.d' ]:
      ensure    => directory,
      require   => Anchor['munin::client::installed'],
      ignore    => 'snmp_*',
      checksum  => mtime,
      recurse   => true,
      purge     => true,
      force     => true,
      notify    => Service['munin-node'],
      owner     => root,
      group     => 0,
      mode      => '0755';
    '/etc/munin/plugin-conf.d/munin-node':
      ensure    => present,
      require   => Anchor['munin::client::installed'],
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
