class Message < ActiveRecord::Base

  validates_presence_of :subject, :contents, :mail_to
  has_many :recipients, :class_name => 'Recipient', :dependent => :destroy

  attr_accessor :mail_to

  def after_initialize
    if new_record?
      self.email_id = User.current.email_id
      self.created_date_time = Time.now
    end
  end

  def formatted_date(display_year = nil)
    format = '%b %d'
    format = '%B %d, %Y' unless display_year.nil?
    created_date_time.strftime format
  end

  def sender
    User.find_by_email_id(self.email_id)
  end

  def sent_to
    ids = recipients.collect {|r| r.email_id}
    User.find_all_by_email_id(ids).collect {|u| u.user_name}.join(',')
  end

  def receivers
    mail_to.split(',').collect {|i| i.strip}
  end

  def validate_receiver_email_ids
    receivers.each {|r|
      u = User.find_by_email_id(r)
      errors.add(:mail_to, "Invalid email id...#{r}") if u.blank?
    }
  end

  def validate
    validate_receiver_email_ids
  end

  def logged_user_email_id?(email_id)
    email_id == self.email_id
  end

  def before_create
    receivers.each {|r|
      recipients.build(:email_id => r) unless logged_user_email_id?(r)
    }
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
