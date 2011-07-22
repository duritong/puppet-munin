class munin::plugins::apache {
  munin::plugin{ [ 'apache_accesses', 'apache_processes', 'apache_volume' ]: }
  munin::plugin::deploy { 'apache_activity': }
}
