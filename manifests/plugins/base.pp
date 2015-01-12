# A basic set of plugins
class munin::plugins::base(
  $df_as_root = false
) {
  # setup basic plugins
  munin::plugin {
    [ 'df', 'cpu', 'interrupts', 'load', 'memory', 'netstat', 'open_files',
      'processes', 'swap', 'uptime', 'users', 'vmstat' ]:
            ensure => present,
  }
  if $df_as_root {
    $df_opt = "user root\n"
  } else {
    $df_opt = ''
  }
  file{'/etc/munin/plugin-conf.d/df':
    content => "[df*]\n${df_opt}env.exclude none unknown iso9660 squashfs udf romfs ramfs debugfs binfmt_misc rpc_pipefs fuse.gvfs-fuse-daemon\n",
    require => Munin::Plugin['df'],
    owner   => 'root',
    group   => 0,
    mode    => '0644',
  }
  include munin::plugins::interfaces

  case $::kernel {
    openbsd: { include munin::plugins::openbsd }
    linux: {
      case $::vserver {
        guest: { include munin::plugins::vserver }
        default: { include munin::plugins::linux }
      }
    }
  }

  case $::virtual {
    physical: { include munin::plugins::physical }
    xen0: { include munin::plugins::dom0 }
    default: { }
  }
}
