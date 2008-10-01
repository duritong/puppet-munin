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
        openbsd: { include munin::client::openbsd }
        darwin: { include munin::client::darwin }
        debian,ubuntu: { include munin::client::debian }
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
	service { 'munin-node':
		ensure => running, 
        enable => true,
        hasstatus => true,
        hasrestart => true,
	}
	file {'/etc/munin/':
			ensure => directory,
			mode => 0755, owner => root, group => 0;
    }
    $real_munin_allow = $munin_allow ? {
        '' => '127.0.0.1',
        default => $munin_allow
    }
    file {'/etc/munin/munin-node.conf':
	    content => template("munin/munin-node.conf.$operatingsystem"),
        notify => Service['munin-node'],
		mode => 0644, owner => root, group => 0,
	}
	munin::register { $fqdn: }
	include munin::plugins::base
}

# currently we install munin on openbsd by hand
# :(
class munin::client::openbsd inherits munin::client::base {
    file{'/usr/src/munin_openbsd.tar.gz':
        source => "puppet://$server/munin/openbsd/package/munin_openbsd.tar.gz",
        owner => root, group => 0, mode => 0600;
    }
    package{ [ 'p5-Compress-Zlib', 'p5-Crypt-SSLeay', 'p5-HTML-Parser', 
                'p5-HTML-Tagset', 'p5-HTTP-GHTTP', 'p5-LWP-UserAgent-Determined',
                'p5-Net-SSLeay', 'p5-Net-Server', 'p5-URI', 'p5-libwww', 'pcre', 'curl' ]:
        ensure => installed,
        before => File['/var/run/munin'],
    }
    exec{'extract_openbsd':
        command => 'cd /;tar xzf /usr/src/munin_openbsd.tar.gz',
        unless => 'test -d /opt/munin',
        require => File['/usr/src/munin_openbsd.tar.gz'],
    }
    file{[ '/var/run/munin', '/var/log/munin' ]:
        ensure => directory,
        require => Exec['extract_openbsd'],
        owner => root, group  => 0, mode => 0755;
    }
    exec{'enable_munin_on_boot':
        command => 'echo "if [ -x /opt/munin/sbin/munin-node ]; then echo -n \' munin\'; /opt/munin/sbin/munin-node; fi" >> /etc/rc.local',
        unless => 'grep -q "munin-node" /etc/rc.local',
        require => File['/var/run/munin'],
    }
    Service['munin-node']{
        restart => '/bin/kill -HUP `/bin/cat /var/run/munin/munin-node.pid`',
        stop => '/bin/kill `/bin/cat /var/run/munin/munin-node.pid`',
        start => '/opt/munin/sbin/munin-node',
        hasstatus => false,
        hasrestart => false,
        require => [ File['/var/run/munin'], File['/var/log/munin'] ],
    }
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

class munin::client::package inherits munin::client::base {
	package { 'munin-node': ensure => installed }
    Service['munin-node']{
        require => Package[munin-node],
    }
    File['/etc/munin/munin-node.conf']{
    	# this has to be installed before the package, so the postinst can
    	# boot the munin-node without failure!
	    before => Package['munin-node'],
    }
}

class munin::client::debian inherits munin::client::package {
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

class munin::client::gentoo inherits munin::client::package {
    Package['munin-node'] {
        name => 'munin',
        category => 'net-analyzer',
    }
    

	include munin::plugins::gentoo
}

class munin::client::centos inherits munin::client::package {
	include munin::plugins::centos
}
