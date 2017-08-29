require 'spec_helper'

describe 'munin::host' do
  let(:pre_condition){ 'package{"munin-node": }
                       service{"munin-node": }' }
  shared_examples 'debian-host' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
      :selinux => false,
      :operatingsystemmajrelease => '9',
      :concat_basedir => '/var/lib/puppet/concat',
    }}
    it { should contain_package('munin') }
    it { should contain_concat('/etc/munin/munin.conf') }
    it { should contain_class('munin::host') }
  end

  shared_examples 'redhat-host' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'RedHat',
      :lsbdistcodename => codename,
      :selinux         => true,
      :operatingsystemmajrelease => '7',
      :concat_basedir  => '/var/lib/puppet/concat',
    }}
    it { should contain_package('munin') }
    it { should contain_concat('/etc/munin/munin.conf') }
    it { should contain_class('munin::host') }
  end

  context 'on debian-like system' do
    it_behaves_like 'debian-host', 'Debian', 'squeeze'
    it_behaves_like 'debian-host', 'Debian', 'wheezy'
    it_behaves_like 'debian-host', 'Ubuntu', 'precise'
  end

  context 'on redhat-like system' do
    it_behaves_like 'redhat-host', 'CentOS', '6'
  end

  context 'on Gentoo' do
    let(:facts) {{
      :osfamily => 'Gentoo',
      :operatingsystem => 'Gentoo',
      :operatingsystemmajrelease => '0',
      :selinux => true,
      :concat_basedir => '/var/lib/puppet/concat',
    }}
    it { should contain_package('munin') }
    it { should contain_concat('/etc/munin/munin.conf') }
    it { should contain_class('munin::host') }
  end
end
