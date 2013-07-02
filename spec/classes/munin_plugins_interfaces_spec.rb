require 'spec_helper'

describe 'munin::plugins::interfaces' do
  context 'on CentOS' do
    let :facts do
      {
        :operatingsystem => 'CentOS',
        :interfaces      => 'lo,eth0,sit0',
      }
    end

    it 'should compile' do
      should include_class('munin::plugins::interfaces')
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

  context 'on OpenBSD' do
    let :facts do
      {
        :operatingsystem => 'OpenBSD',
        :interfaces      => 'eth0',
      }
    end

    it 'should use if_errcoll_ instead of if_err_' do
      should contain_munin__plugin('if_errcoll_eth0').with_ensure('if_errcoll_')
    end
  end
end
