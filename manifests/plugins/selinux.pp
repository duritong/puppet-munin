# SELinux specific plugins
class munin::plugins::selinux {
  munin::plugin{ [ 'selinux_avcstat' ]: }
}
