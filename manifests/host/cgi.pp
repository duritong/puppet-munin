# Set up a munin host using CGI rendering
class munin::host::cgi(
  $owner = 'os_default'
) {
  case $::operatingsystem {
    debian,ubuntu: {
      $document_root = '/var/www/munin'
    }
    default: {
      $document_root = '/var/www/html/munin'
    }
  }
  if $owner == 'os_default' {
    case $::operatingsystem {
      debian,ubuntu: {
        $apache_user = 'www-data'
      }
      default: {
        $apache_user = 'apache'
      }
    }
  } else {
    $apache_user = $owner
  }

  exec{'set_modes_for_cgi':
    command     => "chgrp ${apache_user} /var/log/munin /var/log/munin/munin-graph.log && chmod g+w /var/log/munin /var/log/munin/munin-graph.log && find ${document_root}/* -maxdepth 1 -type d -exec chgrp -R ${apache_user} {} \; && find ${document_root}/* -maxdepth 1 -type d -exec chmod -R g+w {} \;",
    refreshonly => true,
    subscribe   => Concat::Fragment['munin.conf.header'],
  }

  file{'/etc/logrotate.d/munin':
    content => template("${module_name}/logrotate.conf.erb"),
    owner   => root,
    group   => 0,
    mode    => '0644',
  }
}
