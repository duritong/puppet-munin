require 'spec_helper'

describe 'munin::host' do
  shared_examples 'debian-host' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
      :concat_basedir => '/var/lib/puppet/concat',
    }}
    it { should contain_package('munin') }
    it { should contain_file('/etc/munin/munin.conf') }
  end

#  context 'on debian-like system' do
#    it_behaves_like 'debian-host', 'Debian', 'squeeze'
#    it_behaves_like 'debian', 'Debian', 'wheezy'
#    it_behaves_like 'debian', 'Ubuntu', 'precise'
#  end

end
