# munin.pp - everything a sitewide munin installation needs
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# the port is a parameter so vservers can share IP addresses and still be happy

# Define where the individual nodes' configs are stored
$NODESDIR="/var/local/puppet/munin-nodes"

class munin {

class default_client { munin::client { default_munin_node: } }
class default_vserver_client { munin::vserver_client { vserver_munin_node: } }

define client ($port = 4949, $bindhost = "fqdn")
{
	munin::plugin {
		apt: ensure => absent;
		# needs patch for xen-hosts
		iostat: script_path => "/usr/local/bin";
		# others
		[ apt_all, df_abs ]: ;
	}

	munin::base { base:
		port => $port,
		bindhost => $bindhost,
	}
}

define vserver_client ($port = 4950, $bindhost = "fqdn")
{
	munin::plugin {
		[
			apt, cpu, df, df_abs, df_inode, entropy, forks, interrupts, iostat,
			irqstats, load, memory, open_files, open_inodes, swap
		]:
			ensure => absent;
		[ apt_all, netstat, processes]: ;
	}

	munin::base { base:
		port => $port,
		bindhost => $bindhost,
	}
}

define base ($port = 4949, $bindhost = "fqdn")
{
	package { "munin-node":
		ensure => installed,
		require => [ User[munin], Group[munin] ]
	}

	user { munin:
		uid => 203,
		gid => 203,
		home => "/var/lib/munin",
		shell => "/bin/false",
		allowdupe => false,
	}

	group { munin:
		gid => 203,
		allowdupe => false,
	}

	file { 
		["/var/lib/munin", "/var/lib/munin/plugin-state" ]:
			ensure => directory,
			owner => munin, group => munin;
		"/var/run/munin":
			ensure => directory,
			owner => munin;
		"/var/log/munin":
			ensure => directory,
			owner => munin, group => adm;
	}

	replace { set_munin_node_port:
		file => "/etc/munin/munin-node.conf",
		pattern => "^port (?!$port)[0-9]*.*",
		replacement => "port $port",
		notify => Service[munin-node],
		require => Package[munin-node],
	}

	$real_bindhost = $bindhost ? {
		"fqdn" => $fqdn,
		default => $bindhost
	}
	debug("Using bindhost $real_bindhost for $fqdn")

	replace { set_munin_node_bindhost:
		file => "/etc/munin/munin-node.conf",
		pattern => "^host (?!$real_bindhost).*",
		replacement => "host $real_bindhost",
		notify => Service[munin-node],
		require => Package[munin-node],
	}

	line { allow_munin_host:
		file => "/etc/munin/munin-node.conf",
		line => "allow ^$munin_host$",
		ensure => present,
		notify => Service[munin-node],
		require => Package[munin-node],
	}

	line { set_fqdn:
		file => "/etc/munin/munin-node.conf",
		line => "host_name $fqdn",
		ensure => present,
		notify => Service[munin-node],
		require => Package[munin-node],
	}

	@@file { "munin_def_${real_bindhost}_$port": path => "${NODESDIR}/$fqdn",
		ensure => present,
		content => "[$fqdn]\n\taddress $real_bindhost\n\tport $port\n\texim_mailstats.graph_period minute\n\n",
	}

	# TODO: das funktioniert noch nicht g'scheit
	file {
		[ "/etc/munin/plugins", "/etc/munin/plugin-conf.d"] :
			checksum => mtime, ensure => directory,
			require => Package[munin-node],
			notify => Service[munin-node];
		"/etc/munin/munin-node.conf":
			checksum => md5,
			require => Package[munin-node],
	}

	service { munin-node:
		ensure => running, 
		subscribe => [ Package["munin-node"],
			File["/etc/munin/munin-node.conf"],
			Exec[exec_set_munin_node_bindhost],
			Exec[exec_set_munin_node_port],
			User[munin], Group[munin] ],
	}

	# workaround bug in munin_node_configure
	munin::plugin { postfix_mailvolume: ensure => absent }
}


class host {
	err("$fqdn: include inetd")
	package { [munin, micro-httpd]:
		ensure => installed
	}
	append_if_no_such_line { micro-httpd:
		file => "/etc/inetd.conf",
		line => "micro_http_munin  stream tcp nowait.800 nobody  /usr/sbin/micro_httpd micro_httpd_munin /var/www/munin/",
		require => Package[micro-httpd],
	}
	append_if_no_such_line { micro-http-munin-port:
		file => "/etc/services",
		line => "micro_http_munin 81/tcp",
	}

	File <<||>>

	# monitor this file for updates
	$munin_includes = "$splice_dir/munin_conf_includes"
	file { $munin_includes: checksum => md5, }

	exec { create_munin_includes:
		command => "/bin/sh -c '/bin/cat $NODESDIR/* > $munin_includes'",
		subscribe => File[$NODESDIR]
	}

	# create munin.conf
	file_splice { munin_conf_includes:
		file => "/etc/munin/munin.conf",
		input_file => "$splice_dir/munin_conf_includes",
		require => Exec[create_munin_includes],
		subscribe => File[$munin_includes],
	}

	
}

define plugin ($ensure = "present", $script_path = "/usr/share/munin/plugins", $config = '') {
	debug ( "munin_plugin: name=$name, ensure=$ensure, script_path=$script_path" )
	$plugin = "/etc/munin/plugins/$name"
	$plugin_conf = "/etc/munin/plugin-conf.d/$name"
	case $ensure {
		"absent": {
			debug ( "munin_plugin: suppressing $plugin" )
		}
		"present": {
			debug ( "munin_plugin: making $plugin using default $name" )
			file {
				$plugin:
					ensure => "$script_path/$name",
					require => Package[munin-node],
					notify => Service[munin-node],
			}
		}
		default: {
			debug ( "munin_plugin: making $plugin using $ensure" )
			file {
				$plugin:
					ensure => "$script_path/$ensure",
					require => Package[munin-node],
					notify => Service[munin-node],
			}
		}
	}
	case $config {
		'': {
			debug("no config for $name")
			file { $plugin_conf: ensure => absent }
		}
		default: { 
			case $ensure {
				absent: {
					debug("removing config for $name")
					file { $plugin_conf: ensure => absent }
				}
				default: {
					debug("creating $plugin_conf")
					file { $plugin_conf:
						content => "[${name}]\n$config\n",
						mode => 0644, owner => root, group => root,
					}
				}
			}
		}
	}
}


}
