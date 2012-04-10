# currently we install munin on openbsd by targz
# :(
class munin::client::openbsd inherits munin::client::base {
    if $::operatingsystemrelease == '4.3' {
      file{'/usr/src/munin_openbsd.tar.gz':
        source => "puppet:///modules/munin/openbsd/package/munin_openbsd.tar.gz",
        owner => root, group => 0, mode => 0600;
      }
      exec{'extract_openbsd':
        command => 'cd /;tar xzf /usr/src/munin_openbsd.tar.gz',
        unless => 'test -d /opt/munin',
        require => File['/usr/src/munin_openbsd.tar.gz'],
        before => File['/var/run/munin'],
      }
      package{'p5-Compress-Zlib':
        ensure => installed,
        before => File['/var/run/munin'],
      }
    } else {
      package{'munin-node':
        ensure => installed,
      }
    }
    package{ [  'p5-Crypt-SSLeay', 'p5-HTML-Parser', 'p5-HTML-Tagset', 'p5-HTTP-GHTTP',
                'p5-LWP-UserAgent-Determined', 'p5-Net-SSLeay', 'p5-Net-Server',
                'p5-URI', 'p5-libwww', 'pcre', 'curl' ]:
        ensure => installed,
        before => File['/var/run/munin'],
    }
    file{[ '/var/run/munin', '/var/log/munin' ]:
      ensure => directory,
      owner => root, group  => 0, mode => 0755;
    }
    openbsd::rc_local{'munin-node':
        binary => $::operatingsystemrelease ? {
          '4.3' => '/opt/munin/sbin/munin-node',
          default => '/usr/local/sbin/munin-node'
        },
        require => File['/var/run/munin'],
    }
    Service['munin-node']{
        restart => '/bin/kill -HUP `/bin/cat /var/run/munin/munin-node.pid`',
        stop => '/bin/kill `/bin/cat /var/run/munin/munin-node.pid`',
        start => $::operatingsystemrelease ? {
          '4.3' => '/opt/munin/sbin/munin-node',
          default => '/usr/local/sbin/munin-node'
        },
        status => 'test -e /var/run/munin/munin-node.pid && (ps ax | egrep -q "^$(cat /var/run/munin/munin-node.pid).*munin-node")',
        hasstatus => true,
        hasrestart => true,
        require => [ File['/var/run/munin'], File['/var/log/munin'] ],
    }
    cron{'clean_munin_logfile':
        command => 'rm /var/log/munin/munin-node.log; kill -HUP `cat /var/run/munin/munin-node.pid`',
        minute => 0,
        hour => 2,
        weekday => 0,
    }
}
