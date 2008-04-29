# client.pp - configure a munin node
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Adapted and improved by admin(at)immerda.ch

class munin::client {

	$munin_port_real = $munin_port ? { '' => 4949, default => $munin_port } 
	$munin_host_real = $munin_host ? {
		'' => '*',
		'fqdn' => '*',
		default => $munin_host
	}

    case $operatingsystem {
        darwin: { include munin::client::darwin }
        debian: { include munin::client::debian }
        ubuntu: { include munin::client::ubuntu }
        centos: { include munin::client::centos }
        gentoo: { include munin::client::gentoo }
        default: { include munin::client::base }
    }
}

define munin::register()
{
	$munin_port_real = $munin_port ? { '' => 4949, default => $munin_port } 
	$munin_host_real = $munin_host ? {
		'' => $fqdn,
		'fqdn' => $fqdn,
		default => $munin_host
	}

	@@file { "${NODESDIR}/${name}_${munin_port_real}":
		ensure => present,
		content => template("munin/defaultclient.erb"),
		tag => 'munin',
	}
}

define munin::register_snmp()
{
	@@file { "munin_snmp_${name}": path => "${NODESDIR}/${name}",
		ensure => present,
		content => template("munin/snmpclient.erb"),
		tag => 'munin',
	}
}

class munin::client::base {
	package { "munin-node": ensure => installed }
	service { "munin-node":
		ensure => running, 
        enable => true,
        hasstatus => true,
        hasrestart => true,
        require => Package[munin-node],
	}
	file {"/etc/munin/":
			ensure => directory,
			mode => 0755, owner => root, group => 0;
    }
    file {"/etc/munin/munin-node.conf":
			content => template("munin/munin-node.conf.$operatingsystem"),
			mode => 0644, owner => root, group => 0,
			# this has to be installed before the package, so the postinst can
			# boot the munin-node without failure!
			before => Package["munin-node"],
	}
	munin::register { $fqdn: }
	include munin::plugins::base
}

class munin::client::darwin {
	file { "/usr/share/snmp/snmpd.conf": 
		mode => 744,
		content => template("munin/darwin_snmpd.conf.erb"),
		group  => 0,
		owner  => root,
	}
	delete_matching_line{"startsnmpdno":
		file => "/etc/hostconfig",
		pattern => "SNMPSERVER=-NO-",
	}
	line { "startsnmpdyes":
		file => "/etc/hostconfig",
		line => "SNMPSERVER=-YES-",
		notify => Exec["/sbin/SystemStarter start SNMP"],
	}
	exec{"/sbin/SystemStarter start SNMP":
		noop => false,
	} 
	munin::register_snmp { $fqdn: }
}

class munin::client::debian inherits munin::client::base {
    # the plugin will need that
	package { "iproute": ensure => installed }

	Service["munin-node"]{
		# sarge's munin-node init script has no status
		hasstatus => $lsbdistcodename ? { sarge => false, default => true }
	}
    File["/etc/munin/munin-node.conf"]{
			content => template("munin/munin-node.conf.$operatingsystem.$lsbdistcodename"),
    }
	# workaround bug in munin_node_configure
	plugin { "postfix_mailvolume": ensure => absent }
	include munin::plugins::debian
}

class munin::client::ubuntu inherits munin::client::debian {}

class munin::client::gentoo inherits munin::client::base {
    Package['munin-node'] {
        name => 'munin',
        category => 'net-analyzer',
    }
    

	include munin::plugins::gentoo
}

class munin::client::centos inherits munin::client::base {
	include munin::plugins::centos
}
