require 'spec_helper'

describe 'munin::plugins::interfaces' do
  let(:pre_condition){ 'package{"munin-node": }
                       service{"munin-node": }' }
  context 'on CentOS' do
    let :facts do
      {
        :legacy_interfaces => 'lo,eth0,sit0',
        :os => {
          :name => 'CentOS',
          :release => { :major => '7', },
          :selinux => { :enabled => true },
        },
      }
    end

    it 'should compile' do
      should contain_class('munin::plugins::interfaces')
    end

    it 'should create plugins for each interface' do
      # lo
      should contain_munin__plugin('if_lo').with_ensure('if_')
      should contain_munin__plugin('if_err_lo').with_ensure('if_err_')

      # eth0
      should contain_munin__plugin('if_eth0').with_ensure('if_')
      should contain_munin__plugin('if_err_eth0').with_ensure('if_err_')
    end

    it 'should not create plugins for sit0' do
      should_not contain_munin__plugin('if_sit0')
      should_not contain_munin__plugin('if_err_sit0')
    end
  end
end
