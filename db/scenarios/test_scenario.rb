scenario :test do

  create_user(:user_id => 'john', :user_name => 'John Doe', :email_id => 'john@scout.com')
  create_user(:user_id => 'neil', :user_name => 'Neil Mehta', :email_id => 'neil@scout.com')
  create_user(:user_id => 'peter', :user_name => 'Peter Dulmer', :email_id => 'peter@scout.com')

  DAY = 60*60*24
  
  john = User.find_by_user_id('john')
  m1 = create_message(:email_id => john.email_id, :subject => 'Functional requirements session for Inbox project starts at 10:30 am IST',
        :created_date_time => Time.now - DAY)
  m2 = create_message(:email_id => john.email_id, :subject => 'List of people to attend the meeting')

  peter = User.find_by_user_id('peter')
  m3 = create_message(:email_id => peter.email_id, :subject => 'Consultant arrangement for a project')

  neil = User.find_by_user_id('neil')
  create_recipient(:email_id => neil.email_id, :message_id => m1.id, :message_status => "Read")
  create_recipient(:email_id => neil.email_id, :message_id => m2.id, :message_status => "Unread")
  create_recipient(:email_id => neil.email_id, :message_id => m3.id, :message_status => "Deleted")

  create_recipient(:email_id => john.email_id, :message_id => m3.id)

end
