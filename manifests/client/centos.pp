# Install a munin client on centos
class munin::client::centos inherits munin::client::package {
  include munin::plugins::centos
}
