# host.pp - the master host of the munin installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::host {
  package {"munin": ensure => installed, }

  Concat::Fragment <<| tag == 'munin' |>>

  concat::fragment{'munin.conf.header':
    target => '/etc/munin/munin.conf',
    source => [ "puppet:///modules/site-munin/config/host/${::fqdn}/munin.conf.header",
                "puppet:///modules/site-munin/config/host/munin.conf.header.${::operatingsystem}",
                "puppet:///modules/site-munin/config/host/munin.conf.header",
                "puppet:///modules/munin/config/host/munin.conf.header.${::operatingsystem}",
                "puppet:///modules/munin/config/host/munin.conf.header" ],
    order => 05,
  }

  concat{ "/etc/munin/munin.conf":
    owner => root, group => 0, mode => 0644;
  }

  include munin::plugins::muninhost

  if $munin_do_cgi_graphing {
    include munin::host::cgi
  }

  # from time to time we cleanup hanging munin-runs
  file{'/etc/cron.d/munin_kill':
    content => "4,34 * * * * root if $(ps ax | grep -v grep | grep -q munin-run); then killall munin-run; fi\n",
    owner => root, group => 0, mode => 0644;
  }
  if $use_shorewall {
    include shorewall::rules::out::munin
  }
}
