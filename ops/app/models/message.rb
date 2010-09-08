class Message < ActiveRecord::Base

  validates_presence_of :subject, :contents
  has_many :recipients, :class_name => 'Recipient', :dependent => :destroy


  def after_initialize
    if new_record?
      self.email_id = User.current.email_id
      self.created_date_time = Time.now
    end
  end

  def formatted_date
    created_date_time.strftime '%b %d'
  end

  def sender
    User.find_by_email_id(self.email_id)
  end

  def read?
    recipient = recipients.find_by_email_id(User.current.email_id)
    raise "You are not authorized to access this message!!!" unless recipient
    recipient.read?
  end

  def unread?
    recipient = recipients.find_by_email_id(User.current.email_id)
    raise "You are not authorized to access this message!!!" unless recipient
    recipient.unread?
  end
 
end
