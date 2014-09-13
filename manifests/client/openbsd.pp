# generate a few missing things on openbsd
class munin::client::openbsd inherits munin::client::base {
  file{[ '/var/run/munin', '/var/log/munin-node' ]:
    ensure  => directory,
    owner   => root,
    group   => 0,
    mode    => '0755';
  }

  cron{'clean_munin_logfile':
    command => 'rm /var/log/munin-node/munin-node.log; kill -HUP `cat /var/run/munin/munin-node.pid`',
    minute  => 0,
    hour    => 2,
    weekday => 0,
  }
}
