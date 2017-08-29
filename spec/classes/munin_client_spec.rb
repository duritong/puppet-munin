require 'spec_helper'

describe 'munin::client' do
  let(:default_facts){
    {
      :interfaces => 'eth0,eth1',
      :vserver    => false,
      :selinux    => false,
      :acpi_available => false,
      :virtual    => false,
      :kernel     => 'Linux',
    }
  }
  shared_examples 'debian-client' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }.merge(default_facts)}
    it { should contain_package('munin-node') }
    it { should contain_package('iproute') }
    it { should contain_file('/etc/munin/munin-node.conf') }
    it { should contain_class('munin::client::debian') }
  end

  shared_examples 'redhat-client' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily        => 'RedHat',
      :serlinux        => true,
      :lsbdistcodename => codename,
    }.merge(default_facts)}
    it { should contain_package('munin-node') }
    it { should contain_file('/etc/munin/munin-node.conf') }
  end

  context 'on debian-like system' do
    it_behaves_like 'debian-client', 'Debian', 'squeeze'
    it_behaves_like 'debian-client', 'Debian', 'wheezy'
    it_behaves_like 'debian-client', 'Ubuntu', 'precise'
  end

  context 'on redhat-like system' do
    it_behaves_like 'redhat-client', 'CentOS', '6'
    # not supported yet
    # it_behaves_like 'redhat', 'RedHat', '6'
  end

  context 'gentoo' do
    let(:facts) {{
      :operatingsystem           => 'Gentoo',
      :operatingsystemmajrelease => '12',
      :osfamily                  => 'Gentoo',
      :lsbdistcodename           => '',
      :interfaces                => 'lo,eth0',
    }.merge(default_facts)}
    it { should contain_package('munin-node') }
    it { should contain_file('/etc/munin/munin-node.conf') }
    it { should contain_class('munin::client::gentoo') }
  end

end
