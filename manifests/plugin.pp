# plugin.pp - configure a specific munin plugin
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# adapted and improved by admin(at)immerda.ch

define munin::plugin (
  $ensure = "present",
  $script_path_in = '',
  $config = ''
) {
  include munin::plugin::scriptpaths
  $real_script_path = $script_path_in ? { '' => $munin::plugin::scriptpaths::script_path, default => $script_path_in }

  $plugin_src = $ensure ? { "present" => $name, default => $ensure }
  $plugin = "/etc/munin/plugins/${name}"
  $plugin_conf = "/etc/munin/plugin-conf.d/${name}.conf"

  include munin::plugins::setup
  case $ensure {
    "absent": {
      file { $plugin: ensure => absent, }
    }
    default: {
      file { $plugin:
        ensure => "${real_script_path}/${plugin_src}",
        require => $::kernel ? {
          OpenBSD => File['/var/run/munin'],
          default => Package['munin-node']
        },
        notify => Service['munin-node'];
      }
      if ($::selinux == 'true') and (($::operatingsystem != 'CentOS') or ($::operatingsystem == 'CentOS' and $::lsbmajdistrelease != '5')){
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
            content => "[${name}]\n$config\n",
            mode => 0644, owner => root, group => 0,
          }
        }
      }
    }
  }
}
