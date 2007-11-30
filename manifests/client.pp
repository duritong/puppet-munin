# client.pp - configure a munin node
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::client {

	$munin_port_real = $munin_port ? { '' => 4949, default => $munin_port } 
	$munin_host_real = $munin_host ? {
		'' => '*',
		'fqdn' => '*',
		default => $munin_host
	}

	case $operatingsystem {
		darwin: { include munin::client::darwin }
		debian: {
			include munin::client::debian
			include munin::plugins::debian
		}
		ubuntu: {
			info ( "Trying to configure Ubuntu's munin with Debian class" )
			include munin::client::debian
			include munin::plugins::debian
		}
		default: { fail ("Don't know how to handle munin on $operatingsystem") }
	}

	case $kernel {
		linux: {
			case $vserver {
				guest: { include munin::plugins::vserver }
				default: {
					include munin::plugins::linux
					case $virtual {
						xen0: { include munin::plugins::xen }
					}
				}
			}
		}
		default: {
			err( "Don't know which munin plugins to install for $kernel" )
		}
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
	}
}

define munin::register_snmp()
{
	@@file { "munin_snmp_${name}": path => "${NODESDIR}/${name}",
		ensure => present,
		content => template("munin/snmpclient.erb"),
	}
}

class munin::client::darwin 
{
	file { "/usr/share/snmp/snmpd.conf": 
		mode => 744,
		content => template("munin/darwin_snmpd.conf.erb"),
		group  => staff,
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

class munin::client::debian 
{

	package { "munin-node": ensure => installed }

	file {
		"/etc/munin/":
			ensure => directory,
			mode => 0755, owner => root, group => root;
		"/etc/munin/munin-node.conf":
			content => template("munin/munin-node.conf.${operatingsystem}.${lsbdistcodename}"),
			mode => 0644, owner => root, group => root,
			# this has to be installed before the package, so the postinst can
			# boot the munin-node without failure!
			before => Package["munin-node"],
			notify => Service["munin-node"],
	}

	service { "munin-node":
		ensure => running, 
		# sarge's munin-node init script has no status
		hasstatus => $lsbdistcodename ? { sarge => false, default => true }
	}

	munin::register { $fqdn: }

	# workaround bug in munin_node_configure
	plugin { "postfix_mailvolume": ensure => absent }
}

