# Install a munin client on darwin
class munin::client::darwin {
  file { '/usr/share/snmp/snmpd.conf':
    mode    => '0744',
    content => template('munin/darwin_snmpd.conf.erb'),
    group   => 0,
    owner   => root,
  }
  line{'startsnmpdno':
    ensure => absent,
    file   => '/etc/hostconfig',
    line   => 'SNMPSERVER=-NO-',
  }
  line { 'startsnmpdyes':
    file   => '/etc/hostconfig',
    line   => 'SNMPSERVER=-YES-',
    notify => Exec['/sbin/SystemStarter start SNMP'],
  }
  exec{'/sbin/SystemStarter start SNMP':
    noop => false,
  }
  munin::register::snmp { $::fqdn: }
}
