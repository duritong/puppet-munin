class munin::plugins::physical  { 
  case $::kernel {
    linux: { munin::plugin { iostat: } }
  }
}
