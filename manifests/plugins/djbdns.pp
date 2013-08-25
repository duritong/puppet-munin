# Set up the djbdns plugin
class munin::plugins::djbdns {
    munin::plugin::deploy { 'tinydns': }
}
