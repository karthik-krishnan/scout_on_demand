require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Recipient do
  before(:each) do
    @r = Recipient.new
  end

  it do
    @r.should belong_to(:message)
  end

end
