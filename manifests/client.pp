# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Adapted and improved by admin(at)immerda.ch

# configure a munin node
class munin::client(
  $allow                      = [ '127.0.0.1' ],
  $allow6                     = [ '::1' ],
  $host                       = '*',
  $host_to_export             = $facts['fqdn'],
  $host_name                  = $facts['fqdn'],
  $port                       = '4949',
  $use_ssh                    = false,
  $manage_shorewall           = false,
  $shorewall_collector_source = 'net',
  $description                = 'absent',
  $munin_group                = 'absent',
) {

  case $::operatingsystem {
    'OpenBSD': { include munin::client::openbsd }
    'Darwin': { include munin::client::darwin }
    'Debian','Ubuntu': { include munin::client::debian }
    'Gentoo': { include munin::client::gentoo }
    'CentOS': { include munin::client::base }
    default: { include munin::client::base }
  }
  if $munin::client::manage_shorewall {
    if size($allow) < 2 {
      $munin_collector = $allow
    } else {
      $munin_collector  = delete($allow,'127.0.0.1')
    }
    if size($allow6) < 2 {
      $munin_collector6 = $allow6
    } else {
      $munin_collector6  = delete($allow6,'127.0.0.1')
    }
    class{'shorewall::rules::munin':
      munin_port       => $port,
      munin_collector  => $munin_collector,
      munin_collector6 => $munin_collector6,
      collector_source => $shorewall_collector_source,
    }
  }
}
