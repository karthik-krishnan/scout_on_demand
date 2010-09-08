module MessagesHelper

  def mail_to_error_display
    "<div class='error_to'>#{image_tag('error_container.png')} <span>#{@message.errors[:mail_to]}</span></div>" unless @message.errors[:mail_to].nil?
  end

  def subject_error_display
    "<div class='error_subject'>#{image_tag('error_container.png')} <span>#{@message.errors[:subject]}</span></div>" unless @message.errors[:subject].nil?
  end
end
