# Set up the munin plugins for a node
class munin::plugins::setup {

  file {
    [ '/etc/munin/plugins', '/etc/munin/plugin-conf.d' ]:
      ensure    => directory,
      require   => Package['munin-node'],
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
      notify    => Service['munin-node'],
      owner     => root,
      group     => 0,
      mode      => '0640';
  }
}
