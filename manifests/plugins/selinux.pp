# SELinux specific plugins
class munin::plugins::selinux {
  munin::plugin{ [ 'selinux_avcstat' ]: }
  if versioncmp($::operatingsystemmajrelease,'6') > 0 {
    # patch for https://github.com/munin-monitoring/munin/pull/326
    exec{'sed -i \'s/^AVCSTATS=.*/AVCSTATS="\/sys\/fs\/selinux\/avc\/cache_stats"/\' /usr/share/munin/plugins/selinux_avcstat':
      onlyif  => 'grep -q "AVCSTATS=\"/selinux" /usr/share/munin/plugins/selinux_avcstat',
      require => Package['munin-node']
    }
  }
}
