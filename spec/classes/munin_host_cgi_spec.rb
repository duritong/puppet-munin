require 'spec_helper'

describe 'munin::host::cgi' do
  #let :pre_condition do
  #  'include munin::client'
  #end

  context 'on Debian' do
    let :facts do
      { :operatingsystem => 'Debian' }
    end

    it 'should compile' do
      should contain_class('munin::host::cgi')
    end

    it 'should exec set_modes_for_cgi' do
      should contain_exec('set_modes_for_cgi').with({
        :command     => 'chgrp www-data /var/log/munin /var/log/munin/munin-graph.log && chmod g+w /var/log/munin /var/log/munin/munin-graph.log && find /var/www/munin/* -maxdepth 1 -type d -exec chgrp -R www-data {} \; && find /var/www/munin/* -maxdepth 1 -type d -exec chmod -R g+w {} \;',
        :refreshonly => true,
        :subscribe   => 'Concat::Fragment[munin.conf.header]',
      })
    end

    it 'should contain logrotate.conf' do
      should contain_file('/etc/logrotate.d/munin').with({
        :content => /^        create 660 munin www-data$/,
        :group   => 0,
        :mode    => '0644',
        :owner   => 'root',
      })
    end
  end

  context 'on CentOS' do
    let :facts do
      { :operatingsystem => 'CentOS' }
    end

    it 'should exec set_modes_for_cgi' do
      should contain_exec('set_modes_for_cgi').with({
        :command     => 'chgrp apache /var/log/munin /var/log/munin/munin-graph.log && chmod g+w /var/log/munin /var/log/munin/munin-graph.log && find /var/www/html/munin/* -maxdepth 1 -type d -exec chgrp -R apache {} \; && find /var/www/html/munin/* -maxdepth 1 -type d -exec chmod -R g+w {} \;',
        :refreshonly => true,
        :subscribe   => 'Concat::Fragment[munin.conf.header]',
      })
    end

    it 'should contain logrotate.conf' do
      should contain_file('/etc/logrotate.d/munin').with({
        :content => /^        create 660 munin apache$/,
        :group   => 0,
        :mode    => '0644',
        :owner   => 'root',
      })
    end
  end
end
