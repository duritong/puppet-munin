# handle if_ and if_err_ plugins
class munin::plugins::interfaces {

  # filter out many of the useless interfaces that show up
  $real_ifs = reject(split($facts['legacy_interfaces'], ','), 'eth\d+:\d+|eth\d+_\d+|sit0|virbr\d+_nic|vif\d+_\d+|veth(\w+)?\d+|__tmp\d+')

  $ifs = prefix($real_ifs, 'if_')
  $if_errs = prefix($real_ifs, 'if_err_')

  munin::plugin {
    $ifs:
      ensure => 'if_';
    $if_errs:
      ensure => 'if_err_';
  }
}
