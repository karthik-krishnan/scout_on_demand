class IncomingMessagesController < ApplicationController

  def index
    @incoming_messages = User.current.incoming_messages
  end

end
