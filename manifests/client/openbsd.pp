# generate a few missing things on openbsd
class munin::client::openbsd inherits munin::client::base {
  file{[ '/var/run/munin', '/var/log/munin-node' ]:
    ensure  => directory,
    owner   => root,
    group   => 0,
    mode    => '0755';
  }
  openbsd::rc_local{'munin-node':
    binary  => '/usr/local/sbin/munin-node',
    require => File['/var/run/munin'],
  }
  Service['munin-node']{
    restart     => '/bin/kill -HUP `/bin/cat /var/run/munin/munin-node.pid`',
    stop        => '/bin/kill `/bin/cat /var/run/munin/munin-node.pid`',
    start       => '/usr/local/sbin/munin-node',
    status      => 'test -e /var/run/munin/munin-node.pid && (ps ax | egrep -q "^ *$(cat /var/run/munin/munin-node.pid).*munin-node")',
    hasstatus   => true,
    hasrestart  => true,
    require     => [ File['/var/run/munin'], File['/var/log/munin-node'] ],
  }
  cron{'clean_munin_logfile':
    command => 'rm /var/log/munin-node/munin-node.log; kill -HUP `cat /var/run/munin/munin-node.pid`',
    minute  => 0,
    hour    => 2,
    weekday => 0,
  }
}
