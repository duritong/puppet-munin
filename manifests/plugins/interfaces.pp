# handle if_ and if_err_ plugins
class munin::plugins::interfaces {

  $if_err_plugin = $::operatingsystem ? {
    'openbsd' => 'if_errcoll_',
    default   => 'if_err_',
  }

  # filter out many of the useless interfaces that show up
  $real_ifs = reject(split($::interfaces, ' |,'), 'eth\d+_\d+|sit0|virbr\d+_nic|vif\d+_\d+|veth\d+|__tmp\d+')
  $ifs = regsubst($real_ifs, '(.+)', 'if_\1')
  $if_errs = regsubst($real_ifs, '(.+)', "${if_err_plugin}\1")

  munin::plugin { $ifs:
    ensure => 'if_',
  }

  munin::plugin { $if_errs:
    ensure => $if_err_plugin,
  }
}
