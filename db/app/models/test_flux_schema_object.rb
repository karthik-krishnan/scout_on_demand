# == Schema Information
#
# Table name: Addresses
#
#  address_id    :integer(20)     not null, primary key
#  location_addr :string(109)     default(""), not null
#  city_name     :string(35)      default(""), not null
#  state_name    :string(35)      
#  postal_code   :string(15)      default(""), not null
#  country_code  :string(2)       
#  lock_version  :integer(20)     default(0), not null
#

class TestFluxSchemaObject < ActiveRecord::Base
end
