# Set up a munin host using CGI rendering
class munin::host::cgi{
  file{
    '/etc/munin/conf.d/01_cgi.conf':
      content => "graph_strategy cgi
html_strategy cgi
cgiurl_graph /munin/graph\n",
      owner => root,
      group => 0,
      mode  => '0644',
  }

  exec{'set_modes_for_cgi':
    command     => "chgrp ${apache_user} /var/log/munin /var/log/munin/munin-graph.log && chmod g+w /var/log/munin /var/log/munin/munin-graph.log && find ${document_root}/* -maxdepth 1 -type d -exec chgrp -R ${apache_user} {} \; && find ${document_root}/* -maxdepth 1 -type d -exec chmod -R g+w {} \;",
    refreshonly => true,
  }

  file{'/etc/logrotate.d/munin':
    content => template("munin/logrotate.conf.erb"),
    owner   => root,
    group   => 0,
    mode    => '0644',
  }
}
