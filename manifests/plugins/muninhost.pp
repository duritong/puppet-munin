# Set up the plugins for a munin host
class munin::plugins::muninhost {
  munin::plugin { ['munin_update', 'munin_graph']: }
  if $facts['osfamily'] == 'RedHat' and versioncmp($facts['operatingsystemmajrelease'],'7') >= 0  {
    munin::plugin::deploy{'rrdcached': }
  }
}
