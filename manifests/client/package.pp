class munin::client::package inherits munin::client::base {

  case $munin-node_ensure_version {
    '': { $munin-node_ensure_version = "installed" }
  }

  package { 'munin-node': ensure => $munin-node_ensure_version }
  Service['munin-node']{
    require => Package[munin-node],
  }
  File['/etc/munin/munin-node.conf']{
    # this has to be installed before the package, so the postinst can
    # boot the munin-node without failure!
    before => Package['munin-node'],
  }
}
