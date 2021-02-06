# Set up the plugins for a munin host
class munin::plugins::muninhost {
  munin::plugin { ['munin_update', 'munin_graph']: }
  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'],'7') >= 0 {
    munin::plugin::deploy { 'rrdcached': }
  }
}
