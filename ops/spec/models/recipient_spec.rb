require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Recipient do
  before(:each) do
    @r = Recipient.new
  end

  it do
    @r.should belong_to(:message)
  end

end

context Recipient, "on message view" do

  before(:each) do
    @r = Recipient.find_by_email_id_and_message_id('neil@scout.com', 2)
  end

  it "should mark the message as read for the recipient" do
    @r.mark_as_read
    @r.reload
    @r.message_status.should eql(Recipient::READ_STATUS)
  end
end
