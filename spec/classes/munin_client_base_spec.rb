require 'spec_helper'

describe 'munin::client::base' do
  let :default_facts do
    {
      :fqdn => 'munin-node.example.org',
    }
  end

  let :pre_condition do
    'include munin::client'
  end

  context 'on Debian' do
    let :facts do
      { :osfamily => 'Debian' }.merge(default_facts)
    end

    it 'should compile' do
      should contain_class('munin::client::base')
    end

    it 'should set up munin-node' do
      should contain_service('munin-node').with({
        :ensure     => 'running',
        :enable     => true,
        :hasstatus  => true,
        :hasrestart => true,
      })

      should contain_file('/etc/munin').with({
        :ensure => 'directory',
        :mode   => '0755',
        :owner  => 'root',
        :group  => 0,
      })

      should contain_file('/etc/munin/munin-node.conf').
        with_content(/^host_name munin-node.example.org$/).
        with_content(/^allow \^127\\\.0\\\.0\\\.1\$$/).
        with_content(/^host \*$/).
        with_content(/^port 4949$/)

      should contain_munin__register('munin-node.example.org').with({
        :host       => 'munin-node.example.org',
        :port       => '4949',
        :use_ssh    => false,
        :config     => [ 'use_node_name yes', 'load.load.warning 5', 'load.load.critical 10'],
        :export_tag => 'munin',
      })

      should contain_class('munin::plugins::base')
    end

    it 'should contain the Debian specific values' do
      should contain_file('/etc/munin/munin-node.conf').
        with_content(/^log_file \/var\/log\/munin\/munin-node.log$/).
        with_content(/^group root$/)
    end
  end

  context 'on CentOS' do
    let :facts do
      { :osfamily => 'CentOS' }.merge(default_facts)
    end

    it 'should contain the CentOS specific values' do
      should contain_file('/etc/munin/munin-node.conf').
        with_content(/^log_file \/var\/log\/munin-node\/munin-node.log$/).
        with_content(/^group root$/)
    end
  end

  # Disabled because the required openbsd module is not in the requirements
  context 'on OpenBSD', :if => false do
    let :facts do
      { :osfamily => 'OpenBSD' }.merge(default_facts)
    end

    it 'should contain the config OpenBSD specific values' do
      should contain_file('/etc/munin/munin-node.conf').
        with_content(/^log_file \/var\/log\/munin-node\/munin-node.log$/).
        with_content(/^group 0$/)
    end
  end
end
