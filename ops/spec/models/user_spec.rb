require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = User.new
  end

  it do
    @user.should validate_presence_of(:user_id)
  end

  it do
    @user.should validate_presence_of(:user_name)
  end

  it do
    @user.should validate_uniqueness_of(:user_id)
  end

  it do
    @user.should validate_uniqueness_of(:email_id)
  end

end

context User, "Incoming Messages" do
  before(:each) do
    @user = User.find_by_user_id("neil")
  end
  
  it "should show only unread and read messages in the inbox" do
    @user.incoming_messages.size.should eql(2)
  end
  
  it "should not show deleted messages in the inbox" do
    @user.incoming_messages.collect {|m| m.message_status}.include?(Recipient::DELETED_STATUS).should be_false
  end
  
  it "should order the inbox by received date" do
    @user.incoming_messages.first.message.subject.should eql("List of people to attend the meeting")
  end
  
end
