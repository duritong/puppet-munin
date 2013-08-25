# configure a specific munin plugin
define munin::plugin (
  $ensure         = 'present',
  $script_path_in = '',
  $config         = ''
) {
  include munin::plugin::scriptpaths
  $real_script_path = $script_path_in ? { '' => $munin::plugin::scriptpaths::script_path, default => $script_path_in }

  $plugin_src = $ensure ? { 'present' => $name, default => $ensure }
  $plugin = "/etc/munin/plugins/${name}"
  $plugin_conf = "/etc/munin/plugin-conf.d/${name}.conf"

  include munin::plugins::setup
  case $ensure {
    'absent': {
      file { $plugin: ensure => absent, }
    }
    default: {
      $dep = $::kernel ? {
        OpenBSD => File['/var/run/munin'],
        default => Package['munin-node']
      }
      file { $plugin:
        ensure  => "${real_script_path}/${plugin_src}",
        require => $dep,
        notify  => Service['munin-node'];
      }
      if (str2bool($::selinux) == true) and (($::operatingsystem != 'CentOS') or ($::operatingsystem == 'CentOS' and $::lsbmajdistrelease != '5')){
        File[$plugin]{
          seltype => 'munin_etc_t',
        }
      }
    }
  }
  case $config {
    '': {
      file { $plugin_conf: ensure => absent }
    }
    default: {
      case $ensure {
        absent: {
          file { $plugin_conf: ensure => absent }
        }
        default: {
          file { $plugin_conf:
            content => "[${name}]\n${config}\n",
            owner   => root,
            group   => 0,
            mode    => '0640',
          }
        }
      }
    }
  }
}

