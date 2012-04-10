# handle if_ and if_err_ plugins
class munin::plugins::interfaces  { 

  $ifs = regsubst(split($interfaces, " |,"), "(.+)", "if_\\1")
  munin::plugin {
    $ifs: ensure => "if_";
  }
  case $::operatingsystem {
    openbsd: {
      $if_errs = regsubst(split($interfaces, " |,"), "(.+)", "if_errcoll_\\1")
      munin::plugin{
        $if_errs: ensure => "if_errcoll_";
      }
    }
    default: {
      $if_errs = regsubst(split($interfaces, " |,"), "(.+)", "if_err_\\1")
      munin::plugin{
        $if_errs: ensure => "if_err_";
      }
    }
  }
}
