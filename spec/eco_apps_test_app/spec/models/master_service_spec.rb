require 'spec_helper'

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
      lambda{MasterService.reset_config}.should raise_error("master_app_url '#{EcoApps.master_app_url}' is unreachable! Please change it in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml and make sure the master app starts at this address.")
    end
  end

  describe "app" do
    it "should find configration from config file for predefined" do
      MasterService.app(:article).url.should == "http://www.example.com/article"
    end

    describe "get from service" do
      before do
        EcoApps::App.delete_cache("cache_test")
        class TestApp
          def attributes
            {"name" => "cache_test", "url" => "http://test.com"}
          end
        end
        MasterService.stub!(:find).and_return(TestApp.new)
      end

      it "should find configration by service unless it is core" do
        MasterService.app(:cache_test).name.should == "cache_test"
      end

      it "should cache app" do
        MasterService.app(:cache_test)
        MasterService.stub!(:find).and_raise("should not be called")
        MasterService.app(:cache_test).name.should == "cache_test"
      end
    end
    
  end
end

