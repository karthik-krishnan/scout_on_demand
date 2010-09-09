class User < ActiveRecord::Base
  validates_presence_of :user_id, :user_name, :email_id
  validates_uniqueness_of :user_id, :email_id
  
  cattr_accessor :current
  
  def incoming_messages
    Recipient.find(:all, :conditions => ["Recipients.email_id = ? AND message_status in (?)",
        User.current.email_id, [Recipient::UNREAD_STATUS, Recipient::READ_STATUS]], :include => :message, :order => "Messages.created_date_time DESC")
  end

end
