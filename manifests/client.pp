# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Adapted and improved by admin(at)immerda.ch

# configure a munin node
class munin::client(
  $allow                      = [ '127.0.0.1' ],
  $host                       = '*',
  $host_to_export             = $facts['fqdn'],
  $host_name                  = $facts['fqdn'],
  $port                       = '4949',
  $use_ssh                    = false,
  $manage_shorewall           = false,
  $shorewall_collector_source = 'net',
  $export_tag                 = 'munin',
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
    class{'shorewall::rules::munin':
      munin_port       => $port,
      munin_collector  => delete($allow,'127.0.0.1'),
      collector_source => $shorewall_collector_source,
    }
  }
}
