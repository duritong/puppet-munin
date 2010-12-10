class munin::plugins::openbsd inherits munin::plugins::base {

  munin::plugin {
        [ df, cpu, interrupts, load, memory, netstat, open_files,
          processes, swap, users, vmstat, memory_pools, memory_types ]:
            ensure => present,
  }
  
}
