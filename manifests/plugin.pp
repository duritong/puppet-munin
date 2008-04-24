# plugin.pp - configure a specific munin plugin
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# adapted and improved by admin(at)immerda.ch


### configpaths

class munin::plugin::scriptpaths {
	case $operatingsystem {
		gentoo: {	
            $script_path =  "/usr/libexec/munin/plugins"
			}
		debian: {		
            $script_path =  "/usr/share/munin/plugins"
			}
		centos: {		
            $script_path =  "/usr/share/munin/plugins"
			}
		default: {
            $script_path =  "/usr/share/munin/plugins"
		}
	}
}

### defines

define munin::plugin (
	$ensure = "present",
	$script_path_in = '',
	$config = '')
{

    include munin::plugin::scriptpaths
	$real_script_path = $script_path_in ? { '' => $munin::plugin::scriptpaths::script_path, default => $script_path_in }

	$plugin_src = $ensure ? { "present" => $name, default => $ensure }
	debug ( "munin_plugin: name=$name, ensure=$ensure, script_path=$munin::plugin::scriptpaths::script_path" )
	$plugin = "/etc/munin/plugins/$name"
	$plugin_conf = "/etc/munin/plugin-conf.d/$name.conf"
	case $ensure {
		"absent": {
			debug ( "munin_plugin: suppressing $plugin" )
			file { $plugin: ensure => absent, } 
		}
		default: {
			debug ( "munin_plugin: making $plugin using src: $plugin_src" )
			file { $plugin:
			    ensure => "${real_script_path}/${plugin_src}",
				require => Package['munin-node'],
				notify => Service['munin-node'];
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
				script_path_in => "/var/lib/puppet/modules/munin/plugins",
			}
		}
	}
}
define munin::plugin::deploy ($source = '', $ensure = 'present', $config = '') {
    $real_source = $source ? {
        ''  =>  "munin/plugins/$name",
        default => $source
    }
    include munin::plugin::scriptpaths
	debug ( "munin_plugin_${name}: name=$name, source=$source, script_path=$munin::plugin::scriptpaths::script_path" )
    file { "munin_plugin_${name}":
            path => "$munin::plugin::scriptpaths::script_path/${name}",
            source => "puppet://$servername/$real_source",
            ensure => file,
            mode => 0755, owner => root, group => 0;
    }

    munin::plugin{$name: ensure => $ensure, config => $config }
}

### clases for plugins

class munin::plugins::base {
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
				notify => Service['munin-node'];
			"/etc/munin/plugin-conf.d/munin-node":
				ensure => present, 
				mode => 0644, owner => root, group => 0,
				notify => Service['munin-node'],
                before => Package['munin-node'];
		    }
		}
	}
}

# handle if_ and if_err_ plugins
class munin::plugins::interfaces inherits munin::plugins::base {

	$ifs = gsub(split($interfaces, " "), "(.+)", "if_\\1")
	$if_errs = gsub(split($interfaces, " "), "(.+)", "if_err_\\1")
	munin::plugin {
		$ifs: ensure => "if_";
		$if_errs: ensure => "if_err_";
	}
}

class munin::plugins::linux inherits munin::plugins::base {

	munin::plugin {
		[ df_abs, forks, memory, processes, cpu, df_inode, irqstats,
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
	munin::plugin { apt_all: ensure => present; }
}

class munin::plugins::vserver inherits munin::plugins::base {
	munin::plugin {
		[ netstat, processes ]:
			ensure => present;
	}
}

class munin::plugins::gentoo inherits munin::plugins::base {
    munin::plugin::deploy { "gentoo_lastupdated": config => "user portage\nenv.logfile /var/log/emerge.log\nenv.tail        /usr/bin/tail\nenv.grep        /bin/grep"}
}

class munin::plugins::centos inherits munin::plugins::base {
}



class munin::plugins::dom0 inherits munin::plugins::physical {
    munin::plugin::deploy { "xen": config => "user root"}
    munin::plugin::deploy { "xen-cpu": config => "user root"}
    munin::plugin::deploy { "xen_memory": config => "user root"}
    munin::plugin::deploy { "xen_vbd": config => "user root"}
}

class munin::plugins::physical inherits munin::plugins::base {
     munin::plugin { iostat: }
}

class munin::plugins::muninhost inherits munin::plugins::base {
    munin::plugin { munin_update: }
    munin::plugin { munin_graph: }
}

class munin::plugins::domU inherits munin::plugins::base { }

class munin::plugins::djbdns inherits munin::plugins::base {
    munin::plugin::deploy { "tinydns": }
}

class munin::plugins::apache inherits munin::plugins::base {
    munin::plugin{ "apache_accesses": }
    munin::plugin{ "apache_processes": }
    munin::plugin{ "apache_volume": }
    munin::plugin::deploy { "apache_activity": }
}

class munin::plugins::selinux inherits munin::plugins::base {
    munin::plugin::deploy { "selinuxenforced": }
    munin::plugin::deploy { "selinux_avcstats": }
}

class munin::plugins::postgres inherits munin::plugins::base {
    munin::plugin::deploy { "pg_conn": }
    munin::plugin::deploy { "pg__connections": ensure => false }
    munin::plugin::deploy { "pg__locks": ensure => false }
}
