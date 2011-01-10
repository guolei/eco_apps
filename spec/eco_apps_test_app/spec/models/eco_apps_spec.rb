require 'spec_helper'

describe "eco_apps" do

  describe "EcoApps module" do

    describe "master_url validation" do
      it "should not be blank" do
        EcoApps.stub!(:load_from_conf).and_return(nil)
        lambda{EcoApps.validate_master_app_url!}.should raise_error("Please set master_app_url in GEM_DIR/eco_apps/lib/platform_config.yml or APP_ROOT/config/app_config.yml!")
      end

      it "should begin with http or https" do
        EcoApps.stub!(:load_from_conf).and_return("/relative")
        lambda{EcoApps.validate_master_app_url!}.should raise_error("master_app_url must begin with http:// or https://")
      end
      
      it "should select mode" do
        EcoApps.master_app_url.should == "http://test.lan"
      end
    end

    describe "legal_ip validation" do
      it "should not be blank" do
        EcoApps.stub!(:load_from_conf).and_return(nil)
        lambda{EcoApps.validate_legal_ip!}.should raise_error("legal_ip is not identified!")
      end
    end

    describe "in_master_app" do
      it "should be true if master_app equals current name" do
        EcoApps.in_master_app?.should be_false
        EcoApps.current.stub(:name).and_return("master_app_name")
        EcoApps.in_master_app?.should be_true
      end
    end

    it "should get attr defined in config file" do
      EcoApps.secret_key.should == "in app"
      EcoApps.not_exist.should be_nil
      EcoApps.other.should == "some other"
      lambda{EcoApps.master=nil}.should raise_error("undefined method `master=' for EcoApps:Module")
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

end 

