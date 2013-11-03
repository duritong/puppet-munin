# Set up plugins for a linux host
class munin::plugins::linux {
  munin::plugin {
    [ 'df_abs', 'forks', 'df_inode', 'irqstats', 'entropy', 'open_inodes',
      'diskstats', 'proc_pri', 'threads', ]:
      ensure => present;
    'acpi':
      ensure => $::acpi_available;
  }
}
