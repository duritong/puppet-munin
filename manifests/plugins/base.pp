# A basic set of plugins
class munin::plugins::base(
  $df_as_root = false
) {
  ensure_packages(['net-tools'])
  # setup basic plugins
  munin::plugin {
    [ 'df', 'cpu', 'interrupts', 'load', 'memory', 'netstat', 'open_files',
    'processes', 'swap', 'uptime', 'users', 'vmstat' ]:
      ensure => present,
  }
  Package['net-tools'] -> Munin::Plugin['netstat']
  if $df_as_root {
    $df_opt = "user root\n"
  } else {
    $df_opt = undef
  }
  file{'/etc/munin/plugin-conf.d/df':
    content => "[df*]\n${df_opt}env.exclude none unknown iso9660 squashfs udf \
romfs ramfs debugfs binfmt_misc rpc_pipefs fuse.gvfs-fuse-daemon\n",
    require => Munin::Plugin['df'],
    owner   => 'root',
    group   => 0,
    mode    => '0644',
  }
  include munin::plugins::interfaces

  case $facts['kernel'] {
    'openbsd': { include munin::plugins::openbsd }
    'linux': { include munin::plugins::linux }
  }

  case $facts['virtual'] {
    'physical': { include munin::plugins::physical }
    'xen0': { include munin::plugins::dom0 }
    default: { }
  }
}
