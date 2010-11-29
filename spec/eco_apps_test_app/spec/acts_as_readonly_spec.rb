require File.join(File.dirname(__FILE__), 'spec_helper')

describe "acts_as_readonly" do
  describe "not test mode" do
    before do
      Rails.stub!(:env).and_return("development")
      Comment.acts_as_readonly :article
    end

    it "should read data from other database" do
      Comment.table_name_prefix.should == "article_development."
    end

    it "should raise error for write operation" do
      lambda {Comment.create}.should raise_error(ActiveRecord::ReadOnlyRecord)
      lambda {Comment.delete_all}.should raise_error(ActiveRecord::ReadOnlyRecord)
    end
  end

  describe "test mode" do
    it "should use cache table if configured" do
      Comment.acts_as_readonly :article
      Comment.column_names.should == ["id","title","created_at","updated_at"]
    end
  end
end

