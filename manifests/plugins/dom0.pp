# Set up plugins for a Xen dom0 host
class munin::plugins::dom0 {
  munin::plugin::deploy {
    [ 'xen', 'xen_cpu', 'xen_memory', 'xen_mem',
      'xen_vm', 'xen_vbd', 'xen_traffic_all' ]:
      config => 'user root';
  }
}
