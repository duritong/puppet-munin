require 'spec_helper'

describe 'munin::plugin' do
  let(:title) { 'users' }
  let(:facts) do
    { :operatingsystem => 'CentOS' }
  end
  context 'present' do
    it { should contain_file('/etc/munin/plugins/users').with(
      :ensure => 'link',
      :target => '/usr/share/munin/plugins/users'
    ) }
    it { should_not contain_file('/etc/munin/plugin-conf.d/users.conf') }
  end

  context 'present and config' do
    let(:params) do
      { :config => 'env.user root' }
    end
    it { should contain_file('/etc/munin/plugins/users').with(
      :ensure  => 'link',
      :target  => '/usr/share/munin/plugins/users',
      :notify  => 'Service[munin-node]'
    ) }
    it { should contain_file('/etc/munin/plugin-conf.d/users.conf').with(
      :content => "[users]\nenv.user root\n",
      :owner   => 'root',
      :group   => 0,
      :mode    => '0640'
    ) }
  end

  context 'present and config as an array' do
    let(:params) do
      { :config => [ 'env.user root', 'env.group root' ] }
    end
    it { should contain_file('/etc/munin/plugins/users').with(
      :ensure  => 'link',
      :target  => '/usr/share/munin/plugins/users',
      :notify  => 'Service[munin-node]'
    ) }
    it { should contain_file('/etc/munin/plugin-conf.d/users.conf').with(
      :content => "[users]\nenv.user root\nenv.group root\n",
      :owner   => 'root',
      :group   => 0,
      :mode    => '0640'
    ) }
  end

  context 'absent' do
    let(:params) do
      { :ensure => 'absent' }
    end
    it { should_not contain_file('/etc/munin/plugins/users') }
    it { should_not contain_file('/etc/munin/plugin-conf.d/users.conf') }
  end
end
