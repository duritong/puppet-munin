require 'spec_helper'

describe 'munin::client' do
  shared_examples 'debian-client' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}
    it { should contain_package('munin-node') }
    it { should contain_package('iproute') }
    it { should contain_file('/etc/munin/munin-node.conf') }
    it { should contain_class('munin::client::debian') }
  end

  shared_examples 'redhat-client' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily        => 'RedHat',
      :lsbdistcodename => codename,
    }}
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
      :operatingsystem => 'Gentoo',
      :osfamily        => 'Gentoo',
      :lsbdistcodename => '',
      :interfaces      => 'lo,eth0',
    }}
    it { should contain_package('munin-node') }
    it { should contain_file('/etc/munin/munin-node.conf') }
    it { should contain_class('munin::client::gentoo') }
  end

end
