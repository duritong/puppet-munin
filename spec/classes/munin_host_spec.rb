require 'spec_helper'

describe 'munin::host' do
  let :facts do
    {
      :operatingsystem => 'CentOS',
      :interfaces      => 'lo,eth0',
    }
  end

  it 'should compile' do
    should include_class('munin::host')
  end
end
