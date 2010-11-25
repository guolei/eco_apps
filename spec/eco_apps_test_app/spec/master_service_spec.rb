require File.join(File.dirname(__FILE__), 'spec_helper')

describe "master_service" do

  describe "reset_config" do
    it "should post info to core service unless it is core" do
      MasterService.should_receive(:create).once.and_return(true)
      MasterService.reset_config
    end

    it "should raise error if access denied" do
      MasterService.stub!(:create).and_raise(ActiveResource::ForbiddenAccess.new(""))
      lambda{MasterService.reset_config}.should raise_error("Access denied by master app! Please make sure ip address is contained by intranet_ip which is set in GEM_DIR/eco_apps/lib/platform_config.yml")
    end

    it "should raise error if master app can not be reached" do
      MasterService.stub!(:create).and_raise("anything")
      lambda{MasterService.reset_config}.should raise_error("master_app_url '#{EcoApps.master_url}' is unreachable! Please change it in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml and make sure the master app starts at this address.")
    end

    it "should save to database if is core" do
      class EcoAppsStore
        def self.reset_config(options)
          raise 'reset_config'
        end
      end
      lambda{MasterService.reset_config}.should raise_error("reset_config")
    end
  end

  describe "app" do
    it "should find configration by service unless it is core" do
      MasterService.should_receive(:find).once.and_return()
      MasterService.app(:app_name).should == app
    end
    
    it "should find configration from database if it is core" do
      class EcoAppsStore
        def self.reset_config(options)
          AppForTest.new(:name => "test_app_in_master")
        end
      end
      MasterService.app(:test_app).name.should == "test_app_in_master"
    end
    
    it "should find configration from config file for predefined" do
      Rails.stub!(:env).and_return("development")
      EcoApps.in_master_app = false
      MasterService.app(:article).url.should == "http://www.example.com/article"
    end
  end
end

