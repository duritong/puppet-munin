# host.pp - the master host of the munin installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
class munin::host (
  $cgi_graphing = false,
  $use_firewall = false,
) {
  package { 'munin':
    ensure => installed,
  } -> file {
    '/etc/munin/munin-conf.d':
      ensure  => directory,
      owner   => root,
      group   => 0,
      mode    => '0644',
      purge   => true,
      force   => true,
      recurse => true;
  }
  File<<| tag == 'munin_client_register' |>>

  include munin::plugins::muninhost

  package { 'rrdtool':
    ensure => installed,
  } -> file { '/var/lib/munin/rrdcached-journal':
    ensure  => directory,
    owner   => munin,
    group   => munin,
    mode    => '0640',
    require => Package['munin'];
  } -> systemd::unit_file {
    'munin-rrdcached.service':
      source => 'puppet:///modules/munin/config/host/rrdcached.service',
      enable => true,
      active => true,
  } -> file {
    '/etc/munin/munin-conf.d/01_rrdached.conf':
      content => "rrdcached_socket /run/munin/rrdcached.sock\n",
      owner   => root,
      group   => 0,
      mode    => '0644';
  } -> service { 'munin.timer':
    ensure => running,
    enable => true,
  }

  if $cgi_graphing {
    include munin::host::cgi
  }

  # from time to time we cleanup hanging munin-runs
  cron { 'munin_kill':
    command => 'if $(ps ax | grep -v grep | grep -q munin-run); then killall munin-run; fi',
    minute  => ['4', '34'],
    user    => 'root',
  }

  if $use_firewall {
    include firewall::rules::out::munin
  }
}
