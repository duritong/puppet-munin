require 'spec_helper'

describe 'munin::client' do
  shared_examples 'debian' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}
    it { should contain_package('munin-node') }
    it { should contain_package('iproute') }
    it { should contain_file('/etc/munin/munin-node.conf') }
  end

  shared_examples 'redhat' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily        => 'RedHat',
      :lsbdistcodename => codename,
      :interfaces      => 'lo,eth0',
    }}
    it { should contain_package('munin-node') }
    it { should contain_file('/etc/munin/munin-node.conf') }
  end

  context 'on debian-like system' do
    it_behaves_like 'debian', 'Debian', 'squeeze'
    it_behaves_like 'debian', 'Debian', 'wheezy'
    it_behaves_like 'debian', 'Ubuntu', 'precise'
  end

  context 'on redhat-like system' do
    it_behaves_like 'redhat', 'CentOS', '6'
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
  end

end
