class MessagesController < ApplicationController

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(params[:message])
    if @message.valid?
      @message.save!
      redirect_to :controller => 'incoming_messages'
    else
      render :action => :new
    end
  end

  def show
    @message = Message.find(params[:id])
  end
  
end
