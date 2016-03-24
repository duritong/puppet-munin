# Install the munin client on debian
class munin::client::debian inherits munin::client::base {
  # the plugin will need that
  ensure_packages(['iproute'])

  # workaround bug in munin_node_configure
  munin::plugin { 'postfix_mailvolume': ensure => absent }
  include munin::plugins::debian
}
