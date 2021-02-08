# Determine the script path for each OS
class munin::plugin::scriptpaths {
  case $facts['os']['name'] {
    'gentoo': { $script_path =  '/usr/libexec/munin/plugins' }
    'debian': { $script_path =  '/usr/share/munin/plugins' }
    'centos': { $script_path =  '/usr/share/munin/plugins' }
    'openbsd': { $script_path = '/usr/local/libexec/munin/plugins/' }
    default: { $script_path =  '/usr/share/munin/plugins' }
  }
}
