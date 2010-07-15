class munin::plugins::openbsd  { 
  munin::plugin {
    [ memory_pools, memory_types ]:
      ensure => present,
  }
}
