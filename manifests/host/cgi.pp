# Set up a munin host using CGI rendering
class munin::host::cgi {
  selboolean { 'nis_enabled':
    value      => on,
    persistent => true,
  } -> file {
    '/etc/munin/conf.d/01_cgi.conf':
      content => "graph_strategy cgi
html_strategy cgi
cgiurl_graph /munin/graph\n",
      owner   => root,
      group   => 0,
      mode    => '0644',
  }
}
