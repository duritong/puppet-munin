# Set up the plugins for a munin host
class munin::plugins::muninhost {
  munin::plugin { ['munin_update', 'munin_graph']: }
}
