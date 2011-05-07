class munin::plugins::centos inherits munin::plugins::base {
  munin::plugin { users: ensure => present; }
}
