# Set up the plugins for an openbsd host
class munin::plugins::openbsd {
  munin::plugin {
    [ 'memory_pools', 'memory_types' ]:
      ensure => present,
  }
}
