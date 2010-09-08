class Recipient < ActiveRecord::Base

  belongs_to :message
  
  UNREAD_STATUS = 'Unread'
  READ_STATUS = 'Read'
  DELETED_STATUS = 'Deleted'
  
  def read?
    message_status == READ_STATUS
  end
  
  def unread?
    message_status == UNREAD_STATUS
  end
  
end
