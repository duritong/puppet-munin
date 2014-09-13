# install a munin client on gentoo
class munin::client::gentoo inherits munin::client::base {

  Package['munin-node'] {
    name     => 'net-analyzer/munin',
  }

  include munin::plugins::gentoo
}
