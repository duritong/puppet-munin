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
  $shorewall_collector_source = 'net',
  $export_tag = 'munin'
) {
  anchor { 'munin::client::installed': }

  case $::operatingsystem {
    openbsd: {
      class { 'munin::client::openbsd':
        before => Anchor['munin::client::installed']
      }
    }
    darwin: {
      class { 'munin::client::darwin':
        before => Anchor['munin::client::installed']
      }
    }
    debian,ubuntu: {
      class { 'munin::client::debian':
        before => Anchor['munin::client::installed']
      }
    }
    gentoo: {
      class { 'munin::client::gentoo':
        before => Anchor['munin::client::installed']
      }
    }
    centos: {
      class { 'munin::client::package':
        before => Anchor['munin::client::installed']
      }
    }
    default: {
      class { 'munin::client::base':
        before => Anchor['munin::client::installed']
      }
    }
  }
  if $munin::client::manage_shorewall {
    class{'shorewall::rules::munin':
      munin_port       => $port,
      munin_collector  => delete($allow,'127.0.0.1'),
      collector_source => $shorewall_collector_source,
    }
  }
}
