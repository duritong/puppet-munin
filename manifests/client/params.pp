# Set the parameters for the munin client
class munin::client::params {
  $user = 'root'

  case $::osfamily {
    'OpenBSD': {
      $service = 'munin_node'
      $group = '0'
      $log_file = '/var/log/munin-node/munin-node.log'
    }
    'Debian': {
      $service = 'munin_node'
      $group = 'root'
      $log_file = '/var/log/munin/munin-node.log'
    }
    default: {
      $service = 'munin_node'
      $group = 'root'
      $log_file = '/var/log/munin-node/munin-node.log'
    }
  }
}
