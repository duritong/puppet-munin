# client.pp - configure a munin node
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Adapted and improved by admin(at)immerda.ch

class munin::client(
  $allow = [ '127.0.0.1' ],
  $host = '*',
  $port = '4949',
  $use_ssh = false,
  $manage_shorewall = false,
  $shorewall_collector_source = 'net'
) {
  case $::operatingsystem {
    openbsd: { include munin::client::openbsd }
    darwin: { include munin::client::darwin }
    debian,ubuntu: { include munin::client::debian }
    gentoo: { include munin::client::gentoo }
    centos: { include munin::client::package }
    default: { include munin::client::base }
  }
  if $munin::client::manage_shorewall {
    class{'shorewall::rules::munin':
      munin_port => $port,
      munin_collector => delete($allow,'127.0.0.1'),
      collector_source => $shorewall_collector_source,
    }
  }
}
