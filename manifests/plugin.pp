# configure a specific munin plugin
#
# We only manage the plugin if it is not set to absent.
# A plugin (or its config) that should be removed should
# be purged by the recursively managed plugins- or
# config-directory. So we can safe a few resources being
# managed.
define munin::plugin (
  $ensure         = 'present',
  $script_path_in = '',
  $config         = '',
) {
  if $ensure != 'absent' {
    include munin::plugin::scriptpaths
    include munin::plugins::setup
    $real_script_path = $script_path_in ? {
      ''      => $munin::plugin::scriptpaths::script_path,
      default => $script_path_in
    }
    $plugin_src = $ensure ? {
      'present' => $name,
      default   => $ensure
    }

    file { "/etc/munin/plugins/${name}":
      ensure  => link,
      target  =>"${real_script_path}/${plugin_src}",
      notify  => Service['munin-node'];
    }
    if (str2bool($::selinux) == true) and (($::operatingsystem != 'CentOS') or ($::operatingsystem == 'CentOS' and $::lsbmajdistrelease != '5')){
      File["/etc/munin/plugins/${name}"]{
        seltype => 'munin_etc_t',
      }
    }
    if $config != '' {
      file { "/etc/munin/plugin-conf.d/${name}.conf":
        content => "[${name}]\n${config}\n",
        owner   => root,
        group   => 0,
        mode    => '0640',
      }
    }
  }
}

