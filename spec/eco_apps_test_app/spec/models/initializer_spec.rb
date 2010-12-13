require 'spec_helper'

describe "initializer" do

  describe "initializer" do
    it "should copy config file unless it exists" do
      File.exists?(Rails.root.join("config/app_config.yml")).should be_true
    end

    it "should set configuration" do
      EcoApps.master_url.should == "http://test.lan"
      EcoApps.legal_ip.should == [NetAddr::CIDR.create("192.168.0.1/24"), NetAddr::CIDR.create("192.168.1.1/24")]
      EcoApps.current.name.should == "eco_apps_test_app"
      EcoApps.current.url.should == "http://www.example.com/test_app"
      EcoApps.current.api.should == {"url" => {"list" => "/posts"}}
    end
  end
end 

