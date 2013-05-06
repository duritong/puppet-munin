# Set up the plugins for a physical machine
class munin::plugins::physical {
  case $::kernel {
    linux: { munin::plugin { 'iostat': } }
    default: {}
  }
}
