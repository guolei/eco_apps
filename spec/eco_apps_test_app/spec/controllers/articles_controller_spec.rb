require 'spec_helper'

describe ArticlesController do

  describe "helpers" do

    describe "url_of" do
      before do
        Rails.stub!(:env).and_return("development")
      end

      it "should get url from app's configration" do
        controller.url_of(:article, :comments, :article_id => 1).should == "http://www.example.com/article/articles/1/comments"
        controller.url_of(:article, :comments, :article_id => 1, :params=>{:category=>"good"}).should == "http://www.example.com/article/articles/1/comments?category=good"
      end
    end

    describe "full_path_of" do
      it "should return for url begin with http or https" do
        controller.full_path_of("http://test.lan").should == "http://test.lan"
        controller.full_path_of("https://test.lan").should == "https://test.lan"
      end

      describe "development" do
        before do
          Rails.stub!(:env).and_return("development")
        end

        it "should not add app name in for self" do
          controller.full_path_of("/articles").should == "/articles"
        end

        it "should add base_url for other app's url" do
          controller.full_path_of("/articles", "user").should == "http://staging.com/user/articles"
        end
      end

      describe "production" do
        before do
          Rails.stub!(:env).and_return("production")
        end

        it "should add app name if subdomain is www" do
          request.stub!(:subdomains).and_return(["www"])
          controller.full_path_of("/articles").should == "/eco_apps_test_app/articles"
          controller.full_path_of("/articles", :user).should == "/user/articles"
        end

        it "should add not add app name if subdomain is not www " do
          controller.full_path_of("/articles").should == "/articles"
        end
      end
    end

    describe "ip_limited_access" do
      before do
        Rails.stub!(:env).and_return("production")
        EcoApps.stub!(:legal_ip).and_return EcoApps::Util.convert_ip("192.168.1.1/24")
        ApplicationController.ip_limited_access :extra => "10.1.1.1"
      end

      it "should display access denied for illegal access" do
        get :index
        response.body.should == "Access Denied!"
      end

      it "should response successfully for legal access" do
        request.stub!(:remote_ip).and_return("192.168.1.12")
        get :index
        response.body.should == "test"
      end

      it "should response successfully for extra legal access" do
        request.stub!(:remote_ip).and_return("10.1.1.1")
        get :index
        response.body.should == "test"
      end
    end

  end
end

