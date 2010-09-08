
namespace :lfs do
	desc "Regenerate and create MySQL BusinessAccountActivity view per the product sub type definition"
	task :sync_activity_db_view => :environment do
                require 'erb'
                template = ERB.new <<-EOF
                CREATE OR REPLACE VIEW BusinessAccountActivityViews AS
                <% sub_types = ProductSubType.find(:all) %>
                    <% sub_types.each_with_index do |sub_type, index| %>
                    SELECT 
                            b.account_num , b.account_activity_date,  <%= sub_type.default_balance_column %> AS balance_amt
                    FROM 
                            BusinessAccountActivities b, BusinessAccounts ba 
                    WHERE b.account_num = ba.account_num AND ba.product_id in (SELECT product_id FROM Products WHERE 
                            product_sub_type_id = '<%= sub_type.product_sub_type_id %>')
                    <% if index < sub_types.size - 1 %>
                            UNION ALL
                    <% end %>
                <% end %>
                EOF
                ActiveRecord::Base.connection.execute template.result(binding), 'Creating the BusinessAcountActivity View' 
        end
end

