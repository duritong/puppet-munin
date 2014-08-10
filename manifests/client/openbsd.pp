# generate a few missing things on openbsd
class munin::client::openbsd inherits munin::client::base {
  file{[ '/var/run/munin', '/var/log/munin-node' ]:
    ensure  => directory,
    owner   => '_munin-plugin',
    group   => '_munin-plugin',
    mode    => '0775';
  }
}
