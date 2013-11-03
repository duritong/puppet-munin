# handle if_ and if_err_ plugins
class munin::plugins::interfaces {

  # filter out many of the useless interfaces that show up
  $real_ifs = reject(split($::interfaces, ' |,'), 'eth\d+_\d+|sit0|virbr\d+_nic|vif\d+_\d+|veth\d+|__tmp\d+')

  $ifs = prefix($real_ifs, 'if_')

  $if_err_plugin = $::operatingsystem ? {
    'openbsd' => 'if_errcoll_',
    default   => 'if_err_',
  }
  $if_errs = prefix($real_ifs, $if_err_plugin)

  munin::plugin { $ifs:
    ensure => 'if_',
  }

  munin::plugin { $if_errs:
    ensure => $if_err_plugin,
  }
}
