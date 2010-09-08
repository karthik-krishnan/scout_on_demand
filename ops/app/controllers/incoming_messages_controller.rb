class IncomingMessagesController < ApplicationController

  def index
    @recepient_messages = User.current.incoming_messages
  end

end
