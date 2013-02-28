# deploy and register a munin plugin
define munin::plugin::deploy(
  $ensure = 'present',
  $source = '',
  $config = '',
) {
  $plugin_src = $ensure ? {
    'present' => $name,
    'absent'  => $name,
    default   => $ensure
  }
  $real_source = $source ? {
    ''      =>  "munin/plugins/${plugin_src}",
    default => $source
  }
  include munin::plugin::scriptpaths
  file { "munin_plugin_${name}":
    path    => "${munin::plugin::scriptpaths::script_path}/${name}",
    source  => "puppet:///modules/${real_source}",
    owner   => root,
    group   => 0,
    mode    => '0755';
  }

  if ($::selinux == 'true') and (($::operatingsystem != 'CentOS') or ($::operatingsystem == 'CentOS' and $::lsbmajdistrelease != '5')){
    File["munin_plugin_${name}"]{
      seltype =>  'munin_exec_t',
    }
  }

  case $::kernel {
    openbsd: { $basic_require = File['/var/run/munin'] }
    default: { $basic_require = Package['munin-node'] }
  }
  if $require {
    File["munin_plugin_${name}"]{
      require => [ $basic_require, $require ],
    }
  } else {
    File["munin_plugin_${name}"]{
      require => $basic_require,
    }
  }
  # register the plugin
  munin::plugin{$name:
    ensure => $ensure,
    config => $config
  }
  if $require {
    Munin::Plugin[$name]{
      require => $require
    }
  }
}
