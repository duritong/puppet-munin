# deploy and register a munin plugin
define munin::plugin::deploy(
  $ensure   = 'present',
  $source   = undef,
  $config   = undef,
  $seltype  = undef,
  $register = true,
) {
  if $seltype {
    $real_seltype = $seltype
  } elsif versioncmp($::operatingsystemmajrelease,'6') > 0 {
    $real_seltype = 'unconfined_munin_plugin_exec_t'
  } else {
    $real_seltype = 'munin_unconfined_plugin_exec_t'
  }
  $plugin_src = $ensure ? {
    'present' => $name,
    'absent'  => $name,
    default   => $ensure
  }
  if $source {
    $real_source = $source
  } else {
    $real_source = "munin/plugins/${plugin_src}"
  }
  include munin::plugin::scriptpaths
  file { "munin_plugin_${name}":
    path    => "${munin::plugin::scriptpaths::script_path}/${name}",
    source  => "puppet:///modules/${real_source}",
    owner   => root,
    group   => 0,
    mode    => '0755';
  }

  if str2bool($::selinux) and (($::operatingsystem != 'CentOS') or ($::operatingsystem == 'CentOS' and versioncmp($::operatingsystemmajrelease,'5') > 0)){
    File["munin_plugin_${name}"]{
      seltype => $real_seltype,
    }
  }

  case $::kernel {
    'OpenBSD': { $basic_require = File['/var/run/munin'] }
    default: { $basic_require = Package['munin-node'] }
  }
  File["munin_plugin_${name}"]{
    require => $basic_require,
  }

  # register the plugin if required
  if ($register) {
    munin::plugin{$name:
      ensure => $ensure,
      config => $config
    }
  }
}
