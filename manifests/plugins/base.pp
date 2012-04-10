class munin::plugins::base {
  # setup basic plugins
  munin::plugin {
    [ df, cpu, interrupts, load, memory, netstat, open_files,
      processes, swap, uptime, users, vmstat ]:
            ensure => present,
  }
  include munin::plugins::interfaces

  case $::kernel {
    openbsd: { include munin::plugins::openbsd }
    linux: {
      case $vserver {
        guest: { include munin::plugins::vserver }
        default: { include munin::plugins::linux }
      }
    }
  }
        
  case $virtual {
    physical: { include munin::plugins::physical }
    xen0: { include munin::plugins::dom0 }
  }
}
