class munin::plugins::selinux {
  munin::plugin::deploy { [ 'selinuxenforced', 'selinux_avcstats' ]: }
}
