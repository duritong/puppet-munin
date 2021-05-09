# Set up munin plugins for a KVM host
class munin::plugins::kvm {
  munin::plugin::deploy {
    ['kvm_cpu', 'kvm_mem', 'kvm_net']:;
    'kvm_io':
      config => 'user root';
  }
  if versioncmp($facts['os']['release']['major'],'8') < 0 {
    ['kvm_cpu', 'kvm_mem', 'kvm_net', 'kvm_io'].each |$p| {
      Munin::Plugin::Deploy[$p] {
        source => "munin/plugins/${p}.CentOS.${facts['os']['release']['major']}",
      }
    }
  }
}
