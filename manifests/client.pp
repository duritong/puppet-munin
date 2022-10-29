# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Adapted and improved by admin(at)immerda.ch

# configure a munin node
class munin::client (
  Array[Stdlib::IP::Address::V4] $allow = ['127.0.0.1'],
  Array[Stdlib::IP::Address::V6] $allow6 = ['::1'],
  String $host = '*',
  String $host_to_export = $facts['networking']['fqdn'],
  String[1] $host_name = $facts['networking']['fqdn'],
  Stdlib::Port $port = 4949,
  Boolean $use_ssh = false,
  Boolean $use_firewall = false,
  Array[String[1]] $firewall_collector_source = ['net'],
  String[1] $description = 'absent',
  String[1] $munin_group = 'absent',
) {
  case $facts['os']['name'] {
    'OpenBSD': { include munin::client::openbsd }
    'Darwin': { include munin::client::darwin }
    'Debian','Ubuntu': { include munin::client::debian }
    'Gentoo': { include munin::client::gentoo }
    'CentOS': { include munin::client::base }
    default: { include munin::client::base }
  }
  if $munin::client::use_firewall {
    if size($allow) < 2 {
      $munin_collector = $allow
    } else {
      $munin_collector  = delete($allow,'127.0.0.1')
    }
    if size($allow6) < 2 {
      $munin_collector6 = $allow6
    } else {
      $munin_collector6  = delete($allow6,'::1')
    }
    class { 'firewall::rules::munin':
      port             => $port,
      collector        => $munin_collector,
      collector6       => $munin_collector6,
      collector_source => $firewall_collector_source,
    }
  }
}
