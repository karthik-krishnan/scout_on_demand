module FixtureReplacement
  
  attributes_for :user, :class => User do |p|
    p.user_id = nil
    p.user_name = nil
  end

  attributes_for :message, :class => Message do |p|
    p.email_id = nil
    p.subject = 'test'
    p.contents = 'testing message'
    p.created_date_time = Time.now
  end

  attributes_for :recipient, :class => Recipient do |p|
    p.email_id = nil
    p.message_id = nil
    p.message_status = 'Unread'
  end
  
end
    
