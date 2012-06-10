# client.pp - configure a munin node
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Adapted and improved by admin(at)immerda.ch

class munin::client(
  $allow = hiera('munin_client_allow',['127.0.0.1']),
  $host = hiera('munin_host','*'),
  $port = hiera('munin_port','4949')
) {
  case $::operatingsystem {
    openbsd: { include munin::client::openbsd }
    darwin: { include munin::client::darwin }
    debian,ubuntu: { include munin::client::debian }
    gentoo: { include munin::client::gentoo }
    centos: { include munin::client::package }
    default: { include munin::client::base }
  }
  if hiera('use_shorewall',false) {
    include shorewall::rules::munin
  }
}
