# Puppet-Munin

Munin is a performance monitoring system which creates nice RRD graphs and has
a very easy plugin interface. The munin homepage is http://munin.projects.linpro.no/

## Requirements

   * puppet 2.7 or newer
   * install the `concat` and `stdlib` modules -- the munin module depends on functions that are defined and installed via these modules
   * you will need storedconfigs enabled in your puppet setup, to do that you need to add a line to your `puppet.conf` in your `[puppetmasterd]` section which says:

            storeconfigs=true

   * You may wish to immediately setup a `mysql`/ `pgsql` database for your storedconfigs, as
   the default method uses sqlite, and is not very efficient, to do that you need lines
   such as the following below the `storeconfigs=true` line (adjust as needed):

           dbadapter=mysql
           dbserver=localhost
           dbuser=puppet
           dbpassword=puppetspasswd
    
## Usage

   1. Your modules directory will need all the files included in this repository placed 
      under a directory called "munin"

   2. For every host you wish to gather munin statistics, add the class munin::client to that
      node. You will want to set the class parameter `allow` to be the IP(s) of the munin
      collector, this defines what IP is permitted to connect to the node, for example:

          node foo {
            class { 'munin::client': allow => '192.168.0.1'}
          }

      for multiple munin nodes, you can pass an array:

            class { 'munin::client': allow => [ '192.168.0.1', '10.0.0.1' ] }
      
   3. In the node definition in your site.pp for your main munin host, add the following:

            class { 'munin::host': }

      If you want cgi graphing you can pass `cgi_graphing => true`. (For CentOS this is enabled in the default header config) for more information, see: http://munin.projects.linpro.no/wiki/CgiHowto

   4. If there are particular munin plugins you want to enable or configure, you define them
      in the node definition, like follows:

          # Enable monitoring of disk stats in bytes
          munin::plugin { 'df_abs': }

          # Use a non-standard plugin path to use custom plugins
          munin::plugin { 'spamassassin':
             ensure      => present,
             script_path => '/usr/local/share/munin-plugins',
          }
    
          # For wildcard plugins (eg. ip_, snmp_, etc.), use the name variable to
          # configure the plugin name, and the ensure parameter to indicate the base
          # plugin name to which you want a symlink, for example:
          munin::plugin { [ 'ip_192.168.0.1', 'ip_10.0.0.1' ]:
            ensure => 'ip_'
          }
    
          # Use a special config to pass parameters to the plugin
          munin::plugin {
             [ 'apache_accesses', 'apache_processes', 'apache_volume' ]:
                ensure => present,
                config => 'env.url http://127.0.0.1:80/server-status?auto'
          }

   5. If you have Linux-Vservers configured, you will likely have multiple munin-node processes
      competing for the default port 4949, for those nodes, set an alternate port for munin-node
      to run on by putting something similar to the following class parameter:

          class { 'munin::client': allow => '192.168.0.1', port => '4948' }

   6. For deploying plugins which are not available at client, you can fetch them from puppet
      master using `munin::plugin::deploy`.

          munin::plugin::deploy { 'redis':
               source => 'munin/plugins/redis/redis_',
               config => ''   # pass parameters to plugin
          }

      In this example the file on master would be located in `{modulepath}/munin/files/plugins/redis/redis_`.
      Module path is specified in `puppet.conf`, you can find out your `{modulepath}` easily by tying 
      in console `puppet config print modulepath`.