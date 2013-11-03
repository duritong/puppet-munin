# Install a basic munin client
class munin::client::base {
  package { 'munin-node':
    ensure => installed
  }
  service { 'munin-node':
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => Package[munin-node],
  }
  file {'/etc/munin':
    ensure => directory,
    mode   => '0755',
    owner  => root,
    group  => 0,
  }
  file {'/etc/munin/munin-node.conf':
    content => template("munin/munin-node.conf.${::operatingsystem}"),
    # this has to be installed before the package, so the postinst can
    # boot the munin-node without failure!
    before  => Package['munin-node'],
    notify  => Service['munin-node'],
    mode    => '0644',
    owner   => root,
    group   => 0,
  }
  $host = $munin::client::host ? {
    '*'      => $::fqdn,
    default  => $munin::client::host
  }
  munin::register { $::fqdn:
    host       => $host,
    port       => $munin::client::port,
    use_ssh    => $munin::client::use_ssh,
    config     => [ 'use_node_name yes', 'load.load.warning 5', 'load.load.critical 10'],
    export_tag => $munin::client::export_tag,
  }
  include munin::plugins::base
}
