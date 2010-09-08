require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  before(:each) do
    @m = Message.new
    @m.mail_to = "john@scout.com"
  end

  it do
    @m.should validate_presence_of(:subject)
  end


  it do
    @m.should validate_presence_of(:contents)
  end

  it do
    @m.should have_many(:recipients, :class_name => 'Recipient', :dependent => :destroy)
  end

end

context Message, "after initialize" do

  before(:each) do
    @m = Message.new
  end

  it "should default email_id as logged in user's email_id" do
    @m.email_id.should_not be_nil
  end

  it "should default created_date_time as now" do
    @m.created_date_time.should_not be_nil
  end
  
end
