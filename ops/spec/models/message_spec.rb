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
    @m.should validate_presence_of(:mail_to)
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

context Message, "when ask for" do

  before(:each) do
    @sender_email_id = 'peter@scout.com'
    @m = Message.find_by_email_id(@sender_email_id)
  end

  it "should return formatted date without year" do
    a = Time.now
    date = a.strftime '%b %d'
    @m.formatted_date.should eql(date)
  end

  it "should return formatted date with year" do
    a = Time.now
    date = a.strftime '%B %d, %Y'
    @m.formatted_date('display_year').should eql(date)
  end

  it "should return sender" do
    u = User.find_by_email_id(@sender_email_id)
    @m.sender.user_id.should eql(u.user_id)
  end
  
end

context Message, "on Validate" do

  before(:each) do
    User.current = User.find_by_user_id('neil')
    @m = Message.new(:mail_to => 'test@scout.com')
  end

  it "should fail if receiver's email id is not available in the system" do
    @m.valid?
    @m.errors.on(:mail_to).should eql('test@scout.com is invalid')
  end

  it "should not fail if receiver's email id is available in the system" do
    m = Message.new(:mail_to => 'john@scout.com', :subject => 'test', :contents => 'test')
    m.valid?
    m.errors.size.should eql(0)
  end

  it "should fail if send and receiver are same" do
    m = Message.new(:mail_to => 'neil@scout.com')
    m.valid?
    m.errors.on(:mail_to).should eql('You cannot send to your own email id')
  end
  
end

context Message, "on create" do

  before(:each) do
    @m = Message.new(:mail_to => 'john@scout.com,peter@scout.com', :subject => 'test', :contents => 'test')
  end

  it "should send message to recipients" do
    lambda {
      @m.save!
    }.should change(Recipient, :count).by(2)
  end

  it "should not send message if recipient is same as sender" do
    @m.mail_to = 'john@scout.com, peter@scout.com, neil@scout.com'
    lambda {
      @m.save!
    }.should change(Recipient, :count).by(2)
  end

end