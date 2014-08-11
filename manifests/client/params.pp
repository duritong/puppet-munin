# Set the parameters for the munin client
class munin::client::params {
  $user = 'root'

  case $::osfamily {
    'OpenBSD': {
      $service  = 'munin_node'
      $group    = 'wheel'
      $log_file = '/var/log/munin-node/munin-node.log'
    }
    'Debian': {
      $service  = 'munin-node'
      $group    = 'root'
      $log_file = '/var/log/munin/munin-node.log'
    }
    default: {
      $service  = 'munin-node'
      $group    = 'root'
      $log_file = '/var/log/munin-node/munin-node.log'
    }
  }
}
