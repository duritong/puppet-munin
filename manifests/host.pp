# host.pp - the master host of the munin installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::host
{
	package { [ "munin", "nmap"]: ensure => installed, }

	File <<||>>

	concatenated_file { "/etc/munin/munin.conf":
		dir => $NODESDIR,
		header => "/etc/munin/munin.conf.header",
	}
	
}

class munin::snmp_collector
{

	file { 
		"/var/lib/puppet/modules/munin/create_snmp_links":
			source => "puppet://$servername/munin/create_snmp_links.sh",
			mode => 755, owner => root, group => root;
	}

	exec { "create_snmp_links":
		command => "/var/lib/puppet/modules/munin/create_snmp_links $NODESDIR",
		require => File["snmp_links"],
		timeout => "2048",
		schedule => daily
	}
}
