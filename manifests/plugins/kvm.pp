class munin::plugins::kvm {
  munin::plugin::deploy {
    [ 'kvm_cpu', 'kvm_mem', 'kvm_net' ]:;
    'kvm_io':
      config => 'user root';
  }
}
