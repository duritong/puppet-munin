# Set the parameters for the munin client
class munin::client::params {
  $user = 'root'

  case $::osfamily {
    'OpenBSD': {
      $group = '0'
      $log_file = '/var/log/munin-node/munin-node.log'
    }
    'Debian': {
      $group = 'root'
      $log_file = '/var/log/munin/munin-node.log'
    }
    default: {
      $group = 'root'
      $log_file = '/var/log/munin-node/munin-node.log'
    }
  }
}
