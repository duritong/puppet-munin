require 'spec_helper'

describe 'munin::host' do
  let(:pre_condition){ 'package{"munin-node": }
                       service{"munin-node": }' }
  shared_examples 'redhat-host' do |os, release|
    let(:facts) {
      {
        :os => {
          :name => os,
          :release => { :major => release, },
          :selinux => { :enabled => true },
        },
      }
    }
    it { should contain_package('munin') }
    it { should contain_concat('/etc/munin/munin.conf') }
    it { should contain_class('munin::host') }
  end

  context 'on redhat-like system' do
    it_behaves_like 'redhat-host', 'CentOS', '7'
    it_behaves_like 'redhat-host', 'CentOS', '8'
  end
end
