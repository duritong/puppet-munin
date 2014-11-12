# generate a few missing things on openbsd
class munin::client::openbsd inherits munin::client::base {
  file{ '/var/run/munin':
    ensure  => directory,
    owner   => '_munin-plugin',
    group   => '_munin',
    mode    => '0775',
    require => Package['munin-node'],
  }

  file{ '/var/log/munin-node':
    ensure  => directory,
    owner   => '_munin',
    group   => '_munin',
    mode    => '0755',
    require => Package['munin-node'],
  }
}
