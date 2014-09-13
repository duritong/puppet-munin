# generate a few missing things on openbsd
class munin::client::openbsd inherits munin::client::base {
  file{[ '/var/run/munin', '/var/log/munin-node' ]:
    ensure  => directory,
    owner   => root,
    group   => 0,
    mode    => '0755';
  }
}
