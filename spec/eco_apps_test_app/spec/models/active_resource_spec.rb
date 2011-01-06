require 'spec_helper'

describe "active_resource" do

  describe "site=" do
    it "should set url automatically" do
      CommentService.site.to_s.should == "http://www.example.com/article"

      CommentService.site = "article"
      CommentService.site.to_s.should == "http://www.example.com/article"

      CommentService.site = "http://test.com/article"
      CommentService.site.to_s.should == "http://test.com/article"
    end
  end

end 

