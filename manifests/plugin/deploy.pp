# deploy and register a munin plugin
define munin::plugin::deploy (
  $ensure   = 'present',
  $source   = undef,
  $config   = undef,
  $seltype  = undef,
  $register = true,
) {
  if $seltype {
    $real_seltype = $seltype
  } else {
    $real_seltype = 'unconfined_munin_plugin_exec_t'
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
    path   => "${munin::plugin::scriptpaths::script_path}/${name}",
    source => "puppet:///modules/${real_source}",
    owner  => root,
    group  => 0,
    mode   => '0755';
  }

  File["munin_plugin_${name}"] {
    seltype => $real_seltype,
  }

  File["munin_plugin_${name}"] {
    require => Package['munin-node']
  }

  # register the plugin if required
  if $register {
    munin::plugin { $name:
      ensure => $ensure,
      config => $config,
    }
  }
}
