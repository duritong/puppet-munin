class munin::plugin::scriptpaths {
    case $::operatingsystem {
        gentoo: { $script_path =  "/usr/libexec/munin/plugins" }
        debian: { $script_path =  "/usr/share/munin/plugins" }
        centos: { $script_path =  "/usr/share/munin/plugins" }
        openbsd: { $script_path = $::operatingsystemrelease ? {
                                  '4.3' => '/opt/munin/lib/plugins/',
                                  default => '/usr/local/libexec/munin/plugins/'
                  } }
        default: { $script_path =  "/usr/share/munin/plugins" }
    }
}
