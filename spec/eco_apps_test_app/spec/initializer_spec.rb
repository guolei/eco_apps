require File.join(File.dirname(__FILE__), 'spec_helper')

describe "initializer" do

  before do
    MasterService.stub!(:reset_config).and_return(true)
  end

  describe "EcoApps module" do

    describe "master_url validation" do
      it "should not be blank" do
        lambda{EcoApps.master_url=nil}.should raise_error("Please set master_url in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml!")
      end

      it "should begin with http or https" do
        lambda{EcoApps.master_url="/relative"}.should raise_error("master_url must begin with http:// or https://")
      end
      
      it "should select mode" do
        EcoApps.master_url = {"development" => "http://dev.lan", "test" => "http://test.lan"}
        EcoApps.master_url.should == "http://test.lan"
      end
    end

    describe "legal_ip validation" do
      it "should not be blank" do
        lambda{EcoApps.legal_ip=nil}.should raise_error("legal_ip is not identified!")
      end
    end

    describe "in_master_app" do
      it "should be true if EcoAppsStore defined" do
        EcoApps.in_master_app?.should be_false
      end
    end
  end

  describe "EcoApps::App" do
    before do
      @attrs = {"name"=> "test_app", "url" => "http://lan.com", "api" => {"url" => {"list" => "posts"}, "host" => "2000"}, "database" => {"production" => {}}, "else" => {}}
      @app = EcoApps::App.new(@attrs)
    end

    it "should have attributes" do
      @app.eco_apps_config.should == {"url"=>"http://lan.com", "api"=>{"url"=>{"list"=>"posts"}, "host"=>"2000"}, "name"=>"test_app", "database"=>{"production"=>{}}}
    end

    it "should have methods for name, url, api, and database" do
      @app.name.should == "test_app"
      @app.url.should == "http://lan.com"
    end

    it "should find attrs defined in api" do
      @app.host.should == "2000"
    end

    it "should read, write and delete cache from config file" do
      EcoApps::App.write_cache("test_app", {"url" => "http://test.com"})
      EcoApps::App.read_cache("test_app")["url"].should == "http://test.com"
      EcoApps::App.delete_cache("test_app")
      EcoApps::App.read_cache("test_app").should be_nil
    end
  end

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

