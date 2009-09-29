class munin::plugins::nagios inherits munin::plugins::base {
    munin::plugin::deploy {
        nagios_hosts: config => 'user root';
        nagios_svc: config => 'user root';
        nagios_perf_hosts: ensure => nagios_perf_, config => 'user root';
        nagios_perf_svc: ensure => nagios_perf_, config => 'user root';
    }
}
