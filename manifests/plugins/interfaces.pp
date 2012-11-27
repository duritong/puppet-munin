# handle if_ and if_err_ plugins
class munin::plugins::interfaces  {

  # filter out many of the useless interfaces that show up
  $ifs = regsubst(reject(split($::interfaces, ' |,'), 'eth\d+:\d+|sit0|virbr\d+_nic|vif\d+_\d+|veth\d+'), '(.+)', 'if_\\1')

  munin::plugin {
    $ifs: ensure => 'if_';
  }
  case $::operatingsystem {
    openbsd: {
      $if_errs = regsubst(split($::interfaces, ' |,'), '(.+)', 'if_errcoll_\\1')
      munin::plugin{
        $if_errs: ensure => 'if_errcoll_';
      }
    }
    default: {
      $if_errs = regsubst(split($::interfaces, ' |,'), '(.+)', 'if_err_\\1')
      munin::plugin{
        $if_errs: ensure => 'if_err_';
      }
    }
  }
}
