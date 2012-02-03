class munin::client::base(
  $munin_allow = hiera('munin_allow','127.0.0.1')
) {
    service { 'munin-node':
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
    }
    file {'/etc/munin':
        ensure => directory,
        mode => 0755, owner => root, group => 0;
    }
    file {'/etc/munin/munin-node.conf':
        content => template("munin/munin-node.conf.${::operatingsystem}"),
        notify => Service['munin-node'],
        mode => 0644, owner => root, group => 0,
    }
    munin::register { $::fqdn:
        config => [ 'use_node_name yes', 'load.load.warning 5', 'load.load.critical 10'],
    }
    include munin::plugins::base
}
