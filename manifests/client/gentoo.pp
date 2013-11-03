# install a munin client on gentoo
class munin::client::gentoo inherits munin::client::base {

  Package['munin-node'] {
    name     => 'munin',
    category => 'net-analyzer',
  }

  include munin::plugins::gentoo
}
