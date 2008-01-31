# plugin.pp - configure a specific munin plugin
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

define munin::plugin (
	$ensure = "present",
	$script_path = $script_path_default,
	$config = '')
{
	case $operatingsystem {
		debian: {	
			$munin_node_service = "munin-node" 
			$munin_node_package = "munin-node" 
		}
		centos: {	
			$munin_node_service = "munin-node" 
			$munin_node_package = "munin-node" 
		}
		gentoo: {	
			#$munin_node_service = "munin-node"
			$munin_node_service = "munin"
			$munin_node_package = "munin" 
		}
		default: {
			$munin_node_service = "munin-node"
			$munin_node_package = "munin-node" 
		}
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
			debug ( "munin_plugin: making $plugin using src: $plugin_src" )
			case $operatingsystem {
				centos: {	
					file { $plugin:
						ensure => "$script_path/${plugin_src}",
						require => Package[$munin_node_package];
					}
				}
				default: {
					file { $plugin:
						ensure => "$script_path/${plugin_src}",
						require => Package[$munin_node_package],
						notify => Service[$munin_node_service];
					}
				}
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
						mode => 0644, owner => root, group => 0,
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
					mode => 0755, owner => root, group => 0;
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
		gentoo: {	
			$munin_node_package = "munin" 
			$munin_node_service = "munin" 
			}
		debian: {		
			$munin_node_service = "munin-node" 
			$munin_node_package = "munin-node" 
			}
		centos: {		
			$munin_node_service = "munin-node" 
			$munin_node_package = "munin-node" 
			}
		default: {
			$munin_node_service = "munin-node"
			$munin_node_package = "munin-node" 
		}
	}
	case $operatingsystem {
		centos: {		
		    file {
			[ "/etc/munin/plugins", "/etc/munin/plugin-conf.d" ]:
				source => "puppet://$servername/munin/empty",
				ensure => directory, checksum => mtime,
				recurse => true, purge => true, force => true, 
				mode => 0755, owner => root, group => 0;
			"/etc/munin/plugin-conf.d/munin-node":
				ensure => present, 
				mode => 0644, owner => root, group => 0;
		    }
		}

		default: {
		    file {
			[ "/etc/munin/plugins", "/etc/munin/plugin-conf.d" ]:
				source => "puppet://$servername/munin/empty",
				ensure => directory, checksum => mtime,
				recurse => true, purge => true, force => true, 
				mode => 0755, owner => root, group => 0,
				notify => Service["$munin_node_service"];
			"/etc/munin/plugin-conf.d/munin-node":
				ensure => present, 
				mode => 0644, owner => root, group => 0,
				notify => Service[$munin_node_service];
		    }
		}
	}

    case $operatingsystem {
        gentoo: { $script_path_default =  "/usr/libexec/munin/plugins" }
        default: { $script_path_default =  "/usr/share/munin/plugins" }
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
    file { "$script_path_default/gentoo_lastupdated":
            source => "puppet://$servername/munin/plugins/gentoo_lastupdated",
            ensure => file,
            mode => 0755, owner => root, group => 0;
    }

    plugin{"gentoo_lastupdated": ensure => present;}
}

class munin::plugins::centos inherits munin::plugins::base {
}

class munin::plugins::selinux inherits munin::plugins::base {
    file { "$script_path_default/selinuxenforced":
            source => "puppet://$servername/munin/plugins/selinuxenforced",
            ensure => file,
            mode => 0755, owner => root, group => 0;
    }

    plugin{"selinuxenforced": ensure => present;}
}

class munin::plugins::dom0 inherits munin::plugins::base {
    file {
        [ "$script_path_default/xen" ]:
            source => "puppet://$servername/munin/plugins/xen",
            ensure => file, 
            mode => 0755, owner => root, group => 0;
        [ "$script_path_default/xen-cpu" ]:
            source => "puppet://$servername/munin/plugins/xen-cpu",
            ensure => file,
            mode => 0755, owner => root, group => 0;
        [ "$script_path_default/xen_memory" ]:
            source => "puppet://$servername/munin/plugins/xen_memory",
            ensure => file,
            mode => 0755, owner => root, group => 0;
        [ "$script_path_default/xen_vbd" ]:
            source => "puppet://$servername/munin/plugins/xen_vbd",
            ensure => file,
            mode => 0755, owner => root, group => 0;
    }

    plugin {
        [ xen, xen-cpu, xen_memory, xen_vbd ]:
            ensure => present;
    }
}

class munin::plugins::domU inherits munin::plugins::base {
    plugin { if_eth0: ensure => "if_" }
}

class munin::plugins::djbdns inherits munin::plugins::base {
    file {
        [ "$script_path_default/tinydns" ]:
            source => "puppet://$servername/munin/plugins/tinydns",
            ensure => file,
            mode => 0755, owner => root, group => 0;
    }
    plugin {
        [ tinydns ]:
            ensure => present;
    }
}

