# handle if_ and if_err_ plugins
class munin::plugins::interfaces  {

  # filter out many of the useless interfaces that show up
  $real_ifs = reject(split($::interfaces, ' |,'), 'eth\d+_\d+|sit0|virbr\d+_nic|vif\d+_\d+|veth\d+|__tmp\d+')
  $ifs = regsubst($real_ifs, '(.+)', "if_\\1")

  munin::plugin {
    $ifs: ensure => 'if_';
  }
  case $::operatingsystem {
    openbsd: {
      $if_errs = regsubst($real_ifs, '(.+)', "if_errcoll_\\1")
      munin::plugin{
        $if_errs: ensure => 'if_errcoll_';
      }
    }
    default: {
      $if_errs = regsubst($real_ifs, '(.+)', "if_err_\\1")
      munin::plugin{
        $if_errs: ensure => 'if_err_';
      }
    }
  }
}
