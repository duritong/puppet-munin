# Set up plugins for a linux host
class munin::plugins::linux {
  munin::plugin {
    [ 'df_abs', 'forks', 'df_inode', 'irqstats', 'entropy', 'open_inodes' ]:
      ensure => present;
    'acpi':
      ensure => $::acpi_available;
  }
}
