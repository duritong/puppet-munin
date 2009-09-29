# host.pp - the master host of the munin installation
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

class munin::host
{
	package {"munin": ensure => installed, }

	File <<| tag == 'munin' |>>

    file{'/etc/munin/munin.conf.header':
        source => [ "puppet://$server/files/munin/config/host/${fqdn}/munin.conf.header",
                    "puppet://$server/files/munin/config/host/munin.conf.header.$operatingsystem",
                    "puppet://$server/files/munin/config/host/munin.conf.header",
                    "puppet://$server/munin/config/host/munin.conf.header.$operatingsystem",
                    "puppet://$server/munin/config/host/munin.conf.header" ],
        notify => Exec['concat_/etc/munin/munin.conf'],
        owner => root, group => 0, mode => 0644;
    }

	concatenated_file { "/etc/munin/munin.conf":
		dir => $NODESDIR,
		header => "/etc/munin/munin.conf.header",
	}
	
    file { ["/var/log/munin-update.log", "/var/log/munin-limits.log", 
               "/var/log/munin-graph.log", "/var/log/munin-html.log"]:
        ensure => present,
        mode => 640, owner => munin, group => 0;
    }

    include munin::plugins::muninhost

    case $operatingsystem {
        centos: { include munin::host::cgi }
    }

  # from time to time we cleanup hanging munin-runs
  file{'/etc/cron.d/munin_kill':
    content => "4,34 * * * * root if $(ps ax | grep -v grep | grep -q munin-run); then killall munin-run; fi\n",
    owner => root, group => 0, mode => 0644;
  }
  if $use_shorewall {
    include shorewall::rules::out::munin
  }
}

class munin::host::cgi {
    exec{'set_modes_for_cgi':
        command => 'chgrp apache /var/log/munin /var/log/munin/munin-graph.log && chmod g+w /var/log/munin /var/log/munin/munin-graph.log && find /var/www/html/munin/* -maxdepth 1 -type d -exec chgrp -R apache {} \; && find /var/www/html/munin/* -maxdepth 1 -type d -exec chmod -R g+w {} \;',
        refreshonly => true,
        subscribe => File['/etc/munin/munin.conf.header'],
    }

    file{'/etc/logrotate.d/munin':
        source => [ "puppet://$server/files/munin/config/host/${fqdn}/logrotate",
                    "puppet://$server/files/munin/config/host/logrotate.$operatingsystem",
                    "puppet://$server/files/munin/config/host/logrotate",
                    "puppet://$server/munin/config/host/logrotate.$operatingsystem",
                    "puppet://$server/munin/config/host/logrotate" ],
        owner => root, group => 0, mode => 0644;
    }
}

class munin::snmp_collector
{

	file { 
		"/var/lib/puppet/modules/munin/create_snmp_links":
			source => "puppet://$server/munin/create_snmp_links.sh",
			mode => 755, owner => root, group => 0;
	}

	exec { "create_snmp_links":
		command => "/var/lib/puppet/modules/munin/create_snmp_links $NODESDIR",
		require => File["snmp_links"],
		timeout => "2048",
		schedule => daily
	}
}
