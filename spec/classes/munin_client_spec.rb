require 'spec_helper'

describe 'munin::client' do
  let :facts do
    {
      :operatingsystem => 'CentOS',
      :interfaces      => 'lo,eth0',
    }
  end

  it 'should compile' do
    should include_class('munin::client')
  end
end
