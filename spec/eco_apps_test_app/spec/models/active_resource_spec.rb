require 'spec_helper'

describe "active_resource" do

  describe "site=" do
    it "should set url automatically" do
      CommentService.site.to_s.should == "http://www.example.com/article"
    end
  end

end 

