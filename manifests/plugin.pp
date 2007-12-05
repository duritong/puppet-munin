# plugin.pp - configure a specific munin plugin
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

define munin::plugin (
	$ensure = "present",
	$script_path = "/usr/share/munin/plugins",
	$config = '')
{
	case $operatingsystem {
		debian: {	$munin_node_service = "munin-node" }
		gentoo: {	$munin_node_service = "munin" }
	}
	$plugin_src = $ensure ? { "present" => $name, default => $ensure }
	debug ( "munin_plugin: name=$name, ensure=$ensure, script_path=$script_path" )
	$plugin = "/etc/munin/plugins/$name"
	$plugin_conf = "/etc/munin/plugin-conf.d/$name.conf"
	case $ensure {
		"absent": {
			debug ( "munin_plugin: suppressing $plugin" )
			file { $plugin: ensure => absent, } 
		}
		default: {
			$plugin_src = $ensure ? { "present" => $name, default => $ensure }
			debug ( "munin_plugin: making $plugin using src: $plugin_src" )
			file { $plugin:
				ensure => "$script_path/${plugin_src}",
				require => Package[$munin_node_service],
				notify => Service[$munin_node_service],
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

define munin::remoteplugin($ensure = "present", $source, $config = '') {
	case $ensure {
		"absent": { munin::plugin{ $name: ensure => absent } }
		default: {
			file {
				"/var/lib/puppet/modules/munin/plugins/${name}":
					source => $source,
					mode => 0755, owner => root, group => root;
			}
			munin::plugin { $name:
				ensure => $ensure,
				config => $config,
				script_path => "/var/lib/puppet/modules/munin/plugins",
			}
		}
	}
}

class munin::plugins::base {

	case $operatingsystem {
		gentoo: {	$munin_node_service = "munin" }
		debian: {	$munin_node_service = "munin-node" }
	}
		file {
			[ "/etc/munin/plugins", "/etc/munin/plugin-conf.d" ]:
				source => "puppet://$servername/munin/empty",
				ensure => directory, checksum => mtime,
				recurse => true, purge => true, force => true, 
				mode => 0755, owner => root, group => root,
				notify => Service["$munin_node_service-$operatingsystem"];
			"/etc/munin/plugin-conf.d/munin-node":
				ensure => present, 
				mode => 0644, owner => root, group => root,
				notify => Service[$munin_node_service];
		}
}

# handle if_ and if_err_ plugins
class munin::plugins::interfaces inherits munin::plugins::base {

	$ifs = gsub(split($interfaces, " "), "(.+)", "if_\\1")
	$if_errs = gsub(split($interfaces, " "), "(.+)", "if_err_\\1")
	plugin {
		$ifs: ensure => "if_";
		$if_errs: ensure => "if_err_";
	}
}

class munin::plugins::linux inherits munin::plugins::base {

	plugin {
		[ df_abs, forks, iostat, memory, processes, cpu, df_inode, irqstats,
		  netstat, open_files, swap, df, entropy, interrupts, load, open_inodes,
		  vmstat
		]:
			ensure => present;
		acpi: 
			ensure => $acpi_available;
	}

	include munin::plugins::interfaces
}

class munin::plugins::debian inherits munin::plugins::base {

	plugin { apt_all: ensure => present; }

}

class munin::plugins::vserver inherits munin::plugins::base {

	plugin {
		[ netstat, processes ]:
			ensure => present;
	}

}

class munin::plugins::gentoo inherits munin::plugins::base {

}
