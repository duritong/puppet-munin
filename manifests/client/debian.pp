# Install the munin client on debian
class munin::client::debian inherits munin::client::base {
  # the plugin will need that
  ensure_packages(['iproute'])

  $hasstatus = $::lsbdistcodename ? {
    sarge => false,
    default => true
  }

  Service['munin-node']{
    # sarge's munin-node init script has no status
    hasstatus => $hasstatus
  }
  # workaround bug in munin_node_configure
  plugin { 'postfix_mailvolume': ensure => absent }
  include munin::plugins::debian
}
