# Install a basic munin client
class munin::client::base {
  include munin::client::params
  package { 'munin-node':
    ensure => installed,
  } -> file {'/etc/munin/munin-node.conf':
    content => template('munin/munin-node.conf.erb'),
    # this has to be installed before the package, so the postinst can
    # boot the munin-node without failure!
    mode    => '0644',
    owner   => root,
    group   => 0,
  } ~> service { 'munin-node':
    ensure     => running,
    name       => $munin::client::params::service,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package[munin-node],
  }
  file {'/etc/munin':
    ensure => directory,
    mode   => '0755',
    owner  => root,
    group  => 0,
  }
  munin::register { $facts['fqdn']:
    host        => $munin::client::host_to_export,
    port        => $munin::client::port,
    use_ssh     => $munin::client::use_ssh,
    description => $munin::client::description,
    group       => $munin::client::munin_group,
    config      => [ 'use_node_name yes', 'load.load.warning 5',
                      'load.load.critical 10'],
  }
  include munin::plugins::base

  if $munin::client::port != '4949' and str2bool($selinux) {
    selinux::seport{
      "${munin::client::port}":
        setype => 'munin_port_t',
        before => Service['munin-node'];
    }
  }
}
