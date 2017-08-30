# host.pp - the master host of the munin installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
class munin::host(
  $cgi_graphing     = false,
  $cgi_owner        = 'os_default',
  $export_tag       = 'munin',
  $manage_shorewall = false,
  $header_source    = [ "puppet:///modules/site_munin/config/host/${::fqdn}/munin.conf.header",
                "puppet:///modules/site_munin/config/host/munin.conf.header.${::operatingsystem}.${::operatingsystemmajrelease}",
                "puppet:///modules/site_munin/config/host/munin.conf.header.${::operatingsystem}",
                "puppet:///modules/site_munin/config/host/munin.conf.header.${::osfamily}",
                'puppet:///modules/site_munin/config/host/munin.conf.header',
                "puppet:///modules/munin/config/host/munin.conf.header.${::operatingsystem}.${::operatingsystemmajrelease}",
                "puppet:///modules/munin/config/host/munin.conf.header.${::operatingsystem}",
                "puppet:///modules/munin/config/host/munin.conf.header.${::osfamily}",
                'puppet:///modules/munin/config/host/munin.conf.header' ],
) {
  $package = $::operatingsystem ? {
    'OpenBSD' => 'munin-server',
    default   => 'munin'
  }

  package {'munin':
    ensure => installed,
    name   => $package,
  }

  concat{ '/etc/munin/munin.conf':
    owner => root,
    group => 0,
    mode  => '0644',
  }

  Concat::Fragment <<| tag == $export_tag |>>

  concat::fragment{'munin.conf.header':
    target => '/etc/munin/munin.conf',
    source => $header_source,
    order  => '05',
  }

  include munin::plugins::muninhost

  if $cgi_graphing {
    class {'munin::host::cgi':
      owner => $cgi_owner,
    }
  }

  # from time to time we cleanup hanging munin-runs
  cron { 'munin_kill':
    command => 'if $(ps ax | grep -v grep | grep -q munin-run); then killall munin-run; fi',
    minute  => ['4', '34'],
    user    => 'root',
  }

  if $manage_shorewall {
    include shorewall::rules::out::munin
  }
}
