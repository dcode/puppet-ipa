require 'spec_helper'

describe 'ipa', :type => :class do

  context 'with master => true' do
    describe "ipa::init" do
      let(:params) {
        {
          :master  => true,
          :cleanup => false,
          :adminpw => '12345678',
          :dspw    => '12345678',
          :domain  => 'test.domain.org',
          :realm   => 'TEST.DOMAIN.ORG'
        }
      }
      it { should contain_class('ipa::master') }
      it { should contain_package('ipa') }
    end
  end
end
