class munin::host::cgi inherits munin::host {

  case $operatingsystem {
    debian: {
      exec { 'set_modes_for_cgi':
        command => 'chgrp www-data /var/log/munin /var/log/munin/munin-graph.log && chmod g+w /var/log/munin /var/log/munin/munin-graph.log && find /var/cache/munin/www/* -maxdepth 1 -type d -exec chgrp -R www-data {} \; && find /var/www/munin/* -maxdepth 1 -type d -exec chmod -R g+w {} \;',
        refreshonly => true,
        subscribe => File['/etc/munin/munin.conf.header'],
      }
    }
    default: {
      exec { 'set_modes_for_cgi':
        command => 'chgrp apache /var/log/munin /var/log/munin/munin-graph.log && chmod g+w /var/log/munin /var/log/munin/munin-graph.log && find /var/www/html/munin/* -maxdepth 1 -type d -exec chgrp -R apache {} \; && find /var/www/html/munin/* -maxdepth 1 -type d -exec chmod -R g+w {} \;',
        refreshonly => true,
        subscribe => File['/etc/munin/munin.conf.header'],
      }
    }
  }
  
  file{'/etc/logrotate.d/munin':
    source => [ "puppet:///modules/site_munin/config/host/${fqdn}/logrotate",
                "puppet:///modules/site_munin/config/host/logrotate.$operatingsystem",
                "puppet:///modules/site_munin/config/host/logrotate",
                "puppet:///modules/munin/config/host/logrotate.$operatingsystem",
                "puppet:///modules/munin/config/host/logrotate" ],
    owner => root, group => 0, mode => 0644;
  }
}
