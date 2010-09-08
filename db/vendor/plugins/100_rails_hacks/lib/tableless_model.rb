class TablelessModel < ActiveRecord::Base
  self.abstract_class = true
    
  def self.columns
    []
  end
end
