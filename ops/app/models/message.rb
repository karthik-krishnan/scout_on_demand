class Message < ActiveRecord::Base

  validates_presence_of :mail_to, :message => 'Please enter a recipient'
  validates_presence_of :subject, :message => 'Please enter a subject'
  
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
    return [] if mail_to.blank?
    mail_to.split(',').collect {|i| i.strip}
  end

  def validate_receiver_email_ids
    receivers.each {|r|
      u = User.find_by_email_id(r)
      errors.add(:mail_to, "#{r} is invalid") if u.blank?
    }
  end

  def validate_if_sender_and_receiver_are_same
    if receivers.size == 1
      errors.add(:mail_to, "You cannot send to your own email id") if self.email_id == receivers[0]
    end
  end

  def validate
    validate_if_sender_and_receiver_are_same
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

  def recipient
    recipients.find_by_email_id(User.current.email_id)
  end

  def read?
    raise "You are not authorized to access this message!!!" unless recipient
    recipient.read?
  end

  def unread?
    raise "You are not authorized to access this message!!!" unless recipient
    recipient.unread?
  end

  def mark_as_read
    recipient.mark_as_read
  end

end
