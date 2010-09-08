Given /^I as a stockist user "(.*)" is signed on/ do |user|
    $browser.goto @host + "ops"
	$browser.text_field(:name, 'username').value = user
	$browser.text_field(:name, 'password').value = 'test'
	$browser.button(:name, 'submit').click
  assert_successful_response
end


Given /^I logged in mc as "(.*)"/ do |user|
  $browser.goto @host + "mc"
	$browser.text_field(:name, 'username').value = user
	$browser.text_field(:name, 'password').value = 'test'
	$browser.button(:name, 'submit').click
  assert_successful_response
end

Then /I should see accounting tranactions for "(.*)"/ do |text|
  Given %!I go to ops/fin_account_transactions!
  $browser.text.should include_text(text)
  Given %!I follow "Show"!
  $browser.text.should include_text(text)
end

Given /I make a "(.*)" purchase order with "(.*)" payment mode/ do |purchase_type, payment_mode, sku_table|
  Given "I go to ops/purchase_orders/new"
  Given "I fill in \"1234\" for \"Internal Reference\""
  if purchase_type == "Commercial"
    Given "I select \"Commercial Invoice\" from \"Purchase Type\""
  else
    Given "I select \"MOD VAT\" from \"Purchase Type\""
  end
  Given "I select lookup \"Chennai IOCL Depot - IOCL\" for \"Delivery Pref From\""
  if payment_mode == "Credit"
    Given "I choose radio button with id \"record_payment_mode_c\""
  else
    Given "I choose radio button with id \"record_payment_mode_i\""
  end
  Given "I press \"Create\""
  Given %!I see a information message "Created"!
  Given %!I see a open detail view!
  sku_table.hashes.each do |hash|
    Given "I select lookup \"#{hash['sku']}\" for \"Stock Keeping Unit\""
    Given "I set value \"#{hash['qty']}\" for \"Quantity\""
    sleep 1
    Given "I press \"Create\""
    Given "I see a detail view closed"
  end

  Given "I follow \"Confirm\""
  if payment_mode == "Immediate"
    Given "I follow \"Adv. Payment\""
    And %!I make advance payment of value "100000" for "Indian Oil Corporation Ltd"!
    Given %!I see a information message "Created"!
    Given "I go to ops/purchase_orders"
    Given "I follow \"Confirm\""
  end
  Given %!I see a Status cell with value "Created"%!
end

Given /I receive goods of "(.*)" qty for SKU "(.*)"/ do |qty, sku|
  Given "I follow \"Create GRN\""
  Given "I press \"Create\""
  Given %!I see a information message "Created"!
  Given "I follow \"Details\""
  Given "I see a open edit detail view"
  Given "I fill in \"#{qty}\" for \"Saleable Qty\""
  #    Given "I fill in \"today\" for \"Packing Date\""
  Given "I press \"Update\""
  Given %!I see a cell with value "Details available"%!
  Given "I follow \"Confirm\""
end

#Given /I receive goods/ do |sku_table|
#  Given "I follow \"Create GRN\""
#  Given "I press \"Create\""
#  Given %!I see a information message "Created"!
#  sku_table.hashes.each do |hash|
#  Given "I follow id like \"#{hash['sku']}\""
#  sleep 3
#  if hash['sku'] == "2T-SACHET-003"
#    Given "I fill in \"today\" for \"Mfd. Date\""
#  end
#  Given "I fill in \"#{hash['qty']}\" for \"Saleable Qty\""
#  Given "I press \"Update\""
#  Given %!I see a cell with value "Details available"%!
#  end
#  Given "I follow \"Confirm\""
#end

Given /I make a "(.*)" sales order for "(.*)" qty of "(.*)" with "(.*)" collection mode/ do |sales_type, qty, sku, collection_mode|
  Given "I go to ops/sales_orders/new"
  Given "I select lookup \"SVS Traders\" for \"Customer\""
  if sales_type == "Commercial"
    Given "I select \"Commercial Invoice\" from \"Sales Type\""
  else
    Given "I select \"MOD VAT\" from \"Sales Type\""
  end
  Given "I select lookup \"Ram Kumar\" for \"Sales Man\""
  Given "I fill in \"1234\" for \"Internal Ref\""
  if collection_mode == "Credit"
    Given "I choose radio button with id \"record_collection_mode_c\""
  else
    Given "I choose radio button with id \"record_collection_mode_i\""
  end
  Given %!I press "Create"!
  Given %!I see a information message "Created"!
  Given "I see a open new detail view"
  Given "I select lookup \"#{sku}\" for \"SKU\""
  Given %!I set value "#{qty}" for id "record_material_qty"!
  sleep 2
  Given %!I press "Create"!
  Given "I see a detail view closed"
  Given "I follow \"Confirm\""
  if collection_mode == "Immediate"
    Given "I follow \"Adv. Collection\""
    Given %!I receive advance collection of value "100" for "SVS Traders"!
    Given %!I see a information message "Created"!
    Given "I go to ops/sales_orders"
    Given "I follow \"Confirm\""
  end
end

Given /I deliver goods for the sales order ref "(.*)"/ do |ref|
  Given %!I follow "Create Dispatch"!
  Given %!I select lookup "John DSouza" for "Delivery Man"!
  Given %!I fill in "Ref" for "Internal Ref"!
  Given %!I press "Create"!
  Given %!I follow "Confirm"!
end

Given /I record a "(.*)" direct purchase invoice for "(.*)" of "(.*)"/ do |purchase_type, qty, sku|
  Given "I go to ops/purchase_invoices/new"
  Given "I fill in \"inv001\" for \"Vendor Invoice No.\""
  if purchase_type == "Commercial"
    Given "I select \"Commercial Invoice\" from \"Invoice Type\""
  else
    Given "I select \"MOD VAT\" from \"Invoice Type\""
  end
  Given "I select lookup \"Chennai IOCL Depot - IOCL\" for \"Depot\""
  Given "I fill in \"dc01\" for \"Challan No.\""
  Given "I fill in \"today\" for \"Challan Date\""
  Given %!I press "Create"!
  Given %!I see a information message "Created"!
  Given %!I see a open detail view!
  Given "I select lookup \"#{sku}\" for \"Stock Keeping Unit\""
  Given "I set value \"#{qty}\" for \"Item Qty\""
  if purchase_type=="MOD VAT"
    Given "I fill in \"#{qty}\" for \"Assessment Qty\""
    Given "I fill in \"1000\" for \"Assessment Amount\""
  end
  Given "I press \"Create\""
  Given %!I see a detail view closed!
  Given "I follow \"Confirm\""
end

Given /I record a "(.*)" purchase invoice for purchase order ref "(.*)" with sku "(.*)" and qty "(.*)" in my books/ do |purchase_type, ref, sku, qty|
  Given %!I go to ops/purchase_orders!
  Given %!I follow "Create Purchase Inv."!
  Given %!I fill in "inv001" for "Vendor Invoice No."!
  Given %!I select lookup "Chennai IOCL Depot - IOCL" for "Depot"!
  Given %!I fill in "dc01" for "Challan No."!
  Given %!I fill in "today" for "Challan Date"!
  Given %!I press "Create"!
  if purchase_type == "MOD VAT"
    Given %!I follow id like "#{sku}-link"!
    Given "I see a open edit detail view"
    Given %!I set value "#{qty}" for "Assessment Qty"!
    Given %!I set value "1000" for "Assessment Amount"!
    Given "I press \"Update\""
    Given "I see a detail view closed"
  end
  Given %!I follow "Confirm"!
  Given "I go to ops/stock_receipts"
  Given "I follow \"Open\""
  Given "I follow \"Edit\""
  Given "I see a open edit detail view"
  Given "I select lookup \"DC01 - Invoice No. INV001\" for \"Delivery Challan\""
  Given "I press \"Update\""
  Given "I see a detail view closed"

end


Given /I record a direct sales invoice for qty "(.*)" of sku "(.*)"/ do |qty, sku|
  Given "I go to ops/sales_invoices/new"
  Given "I select lookup \"SVS Traders\" for \"Customer\""
  Given "I select lookup \"Ram Kumar\" for \"Sales Man\""
  Given "I select lookup \"John DSouza\" for \"Delivery Man\""
  Given "I fill in \"ref\" for \"Internal Ref.\""
  Given "I choose radio button with id \"record_collection_mode_c\""
  Given "I press \"Create\""
  Given %!I see a information message "Created"!
  Given "I see a open new detail view"
  Given "I select lookup \"#{sku}\" for \"SKU\""
  Given "I set value \"1\" for \"Qty\""
  Given %!I press "Create"!
  Given %!I see a detail view closed!
end

Given /I record a sales invoice for sales order ref "(.*)" in my books/ do |ref|
  Given %!I go to ops/sales_orders!
  Given %!I follow "Create Sales Invoice"!
  Given "I fill in \"ref\" for \"Internal Ref.\""
  Given "I press \"Create\""
  Given %!I follow "Confirm"!
end

Given /I Generate "(.*)" bill/ do |bill_type|
  Given %!I go to ops/#{bill_type}!
  Given %!I see a cell with value "All Goods Received"%!
  Given %!I follow "Generate Bill"!
end

Given /I add a universal customer "(.*)" in "(.*)" module/ do |name, module_name|
 if module_name == 'MC'
     Given "I go to mc/universal_business_entities/new"
  else
    Given "I go to ops/universal_business_entities/new"
  end
  Given "I fill in \"#{name}\" for \"Universal Entity Name\""
  Given "I fill in \"address 1\" for \"Location Address\""
  Given "I fill in \"Che\" for \"City Name\""
  Given "I select lookup \"Andhra Pradesh\" for \"State\""
  Given "I fill in \"600600\" for \"Postal Code\""
  Given "I select lookup \"SA - Super Stockist \" for \"Stockist Category\""
  Given "I select lookup \"Tamil Nadu\" for \"Purchase Zone\""
  Given %!I press "Create"!
end

Given /I add a stockist "(.*)" from universal customers/ do |name|
  Given "I go to mc/universal_business_entities/"
  Given "I follow \"Create Stockist\""
  Given "I fill in \"#{name}\" for \"Stockist Name\""
  Given "I select lookup \"Tamil Nadu\" for \"Zone\""
  Given "I select lookup \"Manager-South\" for \"Reporting To Hierarchy\""
  Given "I fill in \"add\" for \"Location Address\""
  Given "I fill in \"Hyd\" for \"City Name\""
  Given "I select lookup \"Andhra Pradesh\" for \"State\""
  Given "I fill in \"565656\" for \"Postal Code\""
  Given "I select \"Cheque\" from \"Credit Pay By Mode\""
  Given "I select \"Quater Term\" from \"Credit Term\""
  Given "I fill in \"10000\" for \"Credit Limit\""
  Given "I select \"Cash\" from \"Advance Pay By Mode\""
  Given "I fill in \"chq111\" for \"Cheque Details\""
  Given "I fill in \"1111\" for \"Cheque Limit\""
  Given "I fill in \"Samy\" for \"Name\""
  Given "I fill in \"20/10/1955\" for \"Partner Birth Date\""
  Given "I fill in \"65\" for \"Age\""
  Given "I select \"Working Partner\" from \"Partner Classification\""
  Given "I fill in \"100\" for \"Share %\""
  Given "I fill in \"PAN100\" for \"PAN No.\""
  Given "I fill in \"GR100\" for \"GR No.\""
  Given "I fill in \"100\" for \"Salary Payable\""
  Given "I fill in \"222222\" for id like \"record_partner_phone_\""
  Given "I fill in \"9222222\" for id like \"record_partner_mobile_\""
  Given "I fill in \"samy@all.in\" for id like \"record_partner_email_\""
  Given %!I fill in "samy@all.in" for id like "record_partner_email_"!
  Given "I press \"Create\""
end

Given /I add a user "(.*)" for stockist "(.*)"/ do |user_name, stockist_name|
  Given "I go to mc/stockists_new"
  Given %!I see a cell with value "All in all Enterprises"%!
  $browser.link(:text, /Stockist ID/).click
  sleep 5
  $browser.link(:url, /stockists_new\/load_users/).click
  Given "I follow \"Create New\""
  Given "I select lookup \"#{user_name}\" for \"User\""
  Given "I select \"Super User Profile\" from \"User Profile Template Name\""
  Given "I press \"Create\""
end

Given /I add a charges "(.*)" with computation type as "(.*)" for "(.*)"/ do |name, computation_type, customer_type|
  if customer_type == "Stockist"
    Given "I go to mc/internal_charge_definitions/new"
  else
    Given "I go to ops/internal_charge_definitions/new"
  end
  Given %!"I fill in "#{name}" for "Name"!
  Given %!I select "#{computation_type}" from "Computation Type"!
  Given %!I select "RSP / Cum-duty Price" from "Applicable on"!
  Given %!I fill in "10" for "Computation Value"!
  if customer_type == "Stockist"
    Given %!I select lookup "Account Receivable" for "Account Type"!
  else
    Given %!I select lookup "OTHER_CHARGES: Other Charges" with search hint as "other" for "Account"!
  end
    Given %!I press "Create"!
end

Given /I add a discount "(.*)" with id "(.*)" and computation type as "(.*)"/ do |name, id, computation_type|
  Given "I go to mc/purchase_discount_definitions/new"
  Given %!"I fill in "#{id}" for "Id"!
  Given %!"I fill in "#{name}" for "Description"!
  Given %!I select lookup "Account Payable" for "Account Type"!
  Given %!I press "Create"!
  Given %!I follow "Details"!
  Given %!I follow "Create New"!
  Given %!I select lookup "ALL_IN_ALL" for "Customer"!
  Given %!I select lookup "All Products" for "Product Hierarchy"!
  Given %!I select "#{computation_type}" from "Computation Type"!
  Given %!I select "RSP / Cum-duty Price" from "Applicable on"!
  Given %!I fill in "10" for "Computation Value"!
  Given %!I press "Create"!
end

Given /I apply "(.*)" scheme for stockist/ do |scheme_name|
  Given %!I go to mc/default_scheme_definitions !
  Given %!I follow id like "#{scheme_name}"!
  Given %!I check a box with id "record_scheme_definition_active_"!
  Given %!I press "Update"!
end

Given /I define selling agent commission "(.*)"/ do |comm_name|
  Given %!I go to ops/selling_agent_comm_defn !
  Given %!I follow "Create New"!
  Given %!I fill in "#{comm_name}" for "Commisson Definition Id"!
  Given %!I fill in "abc" for "Narrative"!
  Given %!I select lookup "SELLING_AGENT" for "Rule Template"!
  Given %!I press "Create"!
end

Given /I configure margin for "(.*)" / do |product|
  Given %!I go to mc/stockists_new!
  Given %!I see a cell with value "All in all Enterprises"%!
  $browser.link(:text, /Stockist ID/).click
  sleep 5
  Given %!I follow "Configure SKU Details and Product Margins"!
  Given %!I select lookup "#{product}" for "Product"!
  Given %!I fill in "15" for "Amount Less From Ex-Depot Price/RSP"!
  Given %!I press "Update"!
end

Given /I add a universal customer "(.*)" as secondary customer/ do |cust_name|
  Given %!I go to ops/universal_business_entities!
  Given %!I follow "Create Sec.Cust"!
  Given %!I press "Update"!
end

Given /I create a "(.*)" consignment sales order for "(.*)" of "(.*)" with sales type as "(.*)"/ do |purchase_type, qty, sku, sales_type|
  Given "I go to ops/sales_orders/new"
  Given "I select lookup \"SVS Traders\" for \"Customer\""
  Given "I select \"#{purchase_type}\" from \"Sales Type\""
  Given "I select lookup \"Ram Kumar\" for \"Sales Man\""
  Given "I fill in \"test\" for \"Internal Ref\""
  Given %!I select "#{sales_type}" from "Sales Sub Type"!
  Given "I choose radio button with id \"record_collection_mode_c\""
  Given %!I press "Create"!
  Given %!I see a information message "Created"!
  Given "I see a open new detail view"
  Given "I select lookup \"#{sku}\" for \"SKU\""
  Given "I set value \"#{qty}\" for id \"record_material_qty\""
  sleep 5
  Given %!I press "Create"!
  Given %!I see a detail view closed!
  Given %!I follow "Confirm"!
  Given %!I follow "Create PO"!
  #po
  Given "I fill in \"ref\" for \"Internal Reference\""
  Given "I choose radio button with id \"record_payment_mode_c\""
  Given "I press \"Create\""
  Given %!I see a information message "Created"!
  Given "I follow \"Confirm\""
  Given "I follow \"Create GRN\""
  Given "I press \"Create\""
  Given "I follow \"Details\""
  sleep 3
  Given "I fill in \"#{qty}\" for \"Saleable Qty\""
  #    Given "I fill in \"today\" for \"Packing Date\""
  Given "I press \"Update\""
  Given %!I see a detail view closed!
  Given "I follow \"Confirm\""

#PI
  Given "I go to ops/purchase_orders"
  Given %!I follow "Create Purchase Inv."!
  Given "I fill in \"inv001\" for \"Vendor Invoice No.\""
  Given "I select lookup \"Chennai IOCL Depot - IOCL\" for \"Depot\""
  Given "I fill in \"dc01\" for \"Challan No.\""
  Given "I fill in \"today\" for \"Challan Date\""
  Given %!I press "Create"!
  Given %!I see a information message "Created"!
  Given "I follow \"Confirm\""
  Given "I go to ops/stock_receipts"
  Given "I follow \"Open\""
  Given "I follow \"Edit\""
  Given "I see a open edit detail view"
  Given "I select lookup \"DC01 - Invoice No. INV001\" for \"Delivery Challan\""
  Given "I press \"Update\""
  Given %!I see a detail view closed!
  #dispatch
  Given "I go to ops/sales_orders"
  Given %!I follow "Create Dispatch"!
  Given %!I select lookup "John DSouza" for "Delivery Man"!
  Given %!I fill in "Ref" for "Internal Ref"!
  Given %!I press "Create"!
  Given %!I follow "Confirm"!
  sleep 5
  #SI
  Given %!I follow "Create Sales Invoice"!
  Given "I fill in \"ref\" for \"Internal Ref.\""
  Given "I press \"Create\""
  Given %!I follow "Confirm"!
end

Given /I create a request to convert "(.*)" "(.*)" qty of "(.*)" as "(.*)"/ do |qty, from_sku, sku, to_sku|
  Given %!I go to ops/stock_conversions/new!
  Given %!I select lookup "#{sku}" for "Stock"!
  Given %!I select "#{from_sku}" from "Input Stock Type"!
  Given %!I select "#{to_sku}" from "Output Stock Type"!
  Given %!I fill in "#{qty}" for "Qty"!
  Given %!I press "Create"!
end

Given /I approve the "([^"]+)" request/ do |req_name|
  Given %!I logged in mc as "ADMIN1"!
  Given %!I go to mc/#{req_name}!
  Given %!I follow "Approve"!
  Given %!I press "Update"!
  Given %!I follow "View History"!
end

Given /I process the "(.*)" approval/ do |req_name|
  Given %!I logged in mc as "ADMIN1"!
  Given %!I go to mc/#{req_name}!
  Given %!I follow "Approve"!
  Given %!I press "Approve"!
  Given %!I follow "View History"!
end

Given /I accept the "(.*)" approval/ do |req_name|
  Given %!I go to ops/#{req_name}!
  Given %!I follow "Accept approval"!
end

Given /I reject the "([^"]+)" request/ do |req_name|
  Given %!I logged in mc as "ADMIN1"!
  Given %!I go to mc/#{req_name}!
  Given %!I follow "Reject"!
  Given %!I press "Update"!
  Given %!I follow "View History"!
end

Given /I cancel the "(.*)" approval/ do |req_name|
  Given %!I go to ops/#{req_name}!
  Given %!I follow "Cancel"!
end

Given /I shipped the "(.*)" goods/ do |req_name|
  Given %!I go to ops/#{req_name}!
  Given %!I follow "Goods Shipped"!
end

Given /I create a request to repack "(.*)" qty of "(.*)" to "(.*)"/ do |qty, sku_in, sku_out|
  Given %!I go to ops/stock_repacking_register/new!
  Given %!I select lookup "#{sku_in}" for "SKU IN"!
  Given %!I fill in "#{qty}" for "Repack Qty"!
  Given %!I select lookup "#{sku_out}" for "SKU OUT"!
  Given %!I fill in "" for "Output Qty"!
  Given %!I press "Create"!
end

Given /I create a request to add "(.*)" qty of "(.*)"/ do |qty, sku|
  Given %!I go to ops/stock_adjustments/new!
  Given %!I select lookup "#{sku}" for "Stock Keeping Unit"!
  Given %!I fill in "#{qty}" for "Saleable qty"!
  Given %!I fill in "45" for "Ex-Depot Price/RSP"!
  Given %!I fill in "50" for "Purchase price"!
  Given %!I press "Create"!
end

Given /I create a request to delete "(.*)" qty of "(.*)"/ do |qty, sku|
  Given %!I go to ops/stock_adjustments/new!
  Given %!I select lookup "#{sku}" for "Stock"!
  Given %!I fill in "#{qty}" for id like "record_deleted_saleable_qty"!
  Given %!I press "Create"!
end

Given /I make payment of "(.*)" for "(.*)"/ do |amount, payee|
  Given %!I go to ops/payments/new!
  Given %!I select lookup "#{payee}" for "Payee"!
  Given %!I select lookup "VENDOR_PAYMENT - Vendor Payment" for "Payment Type"!
  Given %!I select lookup "Cash" for "Payment Method Type"!
  Given %!I fill in "#{amount}" for "Amount"!
  Given %!I fill in "#{amount}" for "Amount to apply"!
  Given %!I press "Create"!
end

Given /I create a request to return "(.*)" qty of "(.*)"/ do |qty, sku|
  Given %!I go to ops/purchase_returns/new!
  Given %!I fill in "ref" for "Internal Ref."!
  Given "I select lookup \"Chennai IOCL Depot - IOCL\" for \"Depot\""
  Given %!I select lookup "INV001" for "Purchase Invoice"!
  Given %!I select lookup "#{sku}" for "Stock"!
  Given %!I fill in "#{qty}" for "Saleable Qty"!
  Given %!I press "Create"!
end

Given /I creae a sales return request for "(.*)" qty of "(.*)"/ do |qty, sku|
  Given %!I go to ops/sales_returns/new!
  Given %!I select lookup "SVS Traders" for "Customer"!
  Given %!I fill in "ref" for "Internal Ref."!
  Given %!I select lookup "00000001" for "Sales Invoice"!
  Given %!I select lookup "#{sku}" for "Stock"!
  Given %!I fill in "#{qty}" for "Saleable Qty"!
  Given %!I press "Create"!
end

Given /I collect "(.*)" from "(.*)"/ do |amount, payer|
  Given %!I go to ops/collections/new!
  Given %!I select lookup "#{payer}" for "Payer"!
  Given %!I select lookup "CUSTOMER_PAYMENT - Customer Payment" for "Collection Type"!
  Given %!I select lookup "Cash" for "Collection Method Type"!
  Given %!I press "Create"!
end

Given /I create a "(.*)" voucher of value "(.*)" for "(.*)"/ do |vouchers_type, amount, beneficiary|
  voucher_url_suffix = vouchers_type == "payable" ? 'payable_vouchers' : 'receivable_vouchers'
  Given %!I go to ops/#{voucher_url_suffix}!
  Given %!I follow "Create New"!
    if vouchers_type == "payable"
      Given %!I select lookup "#{beneficiary}" for "Payee"!
      Given %!I select lookup "DIRECT_EXPENSE: Direct Expense" with search hint as "direc" for "Debit GL Account"!
      sleep 2
    else
      Given %!I select lookup "#{beneficiary}" for "Payer"!
      Given %!I select lookup "DIRECT_INCOME: Direct Income" with search hint as "income" for "Credit GL Account"!
      sleep 2
    end
  Given %!I select "Trading" from "Type"!
  Given %!I press "Create"!
  Given %!I see a information message "Created"!
  Given "I see a open new detail view"
  Given %!I select "Goods" from "Type"!
  Given %!I fill in "10" for "Quantity"!
  Given %!I fill in "#{amount}" for "Amount"!
  Given %!I press "Create"!
  Given %!I see a detail view closed!
  Given %!I go to ops/#{voucher_url_suffix}!
  Given %!I see a Status cell with value "Draft"!
  Given %!I follow "Confirm"!
end

Given /I create a tax definition "(.*)" for "(.*)" applicable for "(.*)"/ do |tax_defn, state, applicable_on|
  Given %!I go to mc/tax_definition_masters/new!
  Given %!I fill in "#{tax_defn}" for "Tax Definition"!
  Given %!I fill in "spl tax" for "Description"!
  Given %!I select "#{state}" from "State Scope"!
  Given %!I select "Tax Register" from "Applicable Register"!
  Given %!I select "#{applicable_on}" from "Applicable For"!
  Given %!I select lookup "Account Payable" for "Receivable Account Type"!
  Given %!I select lookup "Account Receivable" for "Payable Account Type"!
  Given %!I press "Create"!
end

Given /I create commission schedule "(.*)" for "(.*)"/ do |frequency, sales_type|
  Given %!I go to mc/commission_schedules!
  Given %!I follow "Create New"!
  Given %!I select "#{sales_type}" from "Schedule Type"!
  Given %!I select "#{frequency}" from "Frequency"!
  Given %!I press "Create"!
end

Given /I make advance payment of value "(.*)" for "(.*)"/ do |amount, payee|
  Given %!I go to ops/payments/new?payment_mode=A!
  Given %!I select lookup "#{payee}" for "Payee"!
  Given %!I select lookup "Cash" for "Payment Method Type"!
  Given %!I fill in "#{amount}" for "Amount"!
  Given %!I press "Create"!
end

Given /I receive advance collection of value "(.*)" for "(.*)"/ do |amount, payer|
  Given %!I go to ops/collections/new?auto_refresh=&collection_mode=A&record_select_field!
  Given %!I select lookup "#{payer}" for "Payer"!
  Given %!I select lookup "Cash" for "Collection Method Type"!
  Given %!I fill in "#{amount}" for "Amount"!
  Given %!I press "Create"!
end

Given /I create a sales discount "(.*)" with computation type as "(.*)"/ do |name, computation_type|
  Given "I go to ops/internal_sales_discount_definitions/new"
  Given %!"I fill in "#{name}" for "Description"!
  Given %!I select "#{computation_type}" from "Computation Type"!
  Given %!I select "RSP / Cum-duty Price" from "Applicable on"!
  Given %!I fill in "10" for "Computation Value"!
  Given %!I select lookup "SELLING_EXPENSES: Selling Expenses" with search hint as "selling" for "Gl Account"!
  Given %!I press "Create"!
end

Given /I configure "(.*)"  as "(.*)" for geographical location "(.*)"/ do |pricing_type, amount, geo_hierarchy|
  Given %!I go to mc/products!
  Given %!I follow "#{pricing_type}"!
  Given %!I follow "Create New"!
  Given %!I select lookup "#{geo_hierarchy}" for "Geographical Hierarchy"!
  if pricing_type == "Configure Product Pack Price"
    Given %!I select lookup "Carton" for "Pack"!
  end
  Given %!I fill in "#{amount}" for "Ex-Depot Price/RSP"!
  Given %!I press "Create"!
end

Given /I create a transaction series for "(.*)"/ do |transaction_type|
  Given %!I go to ops/transaction_series/new!
  Given %!I fill in "new_trans_series" for "Series name"!
  Given %!I select "#{transaction_type}" from "Transaction Type"!
  Given %!I select "None" from "Cycle Frequency"!
  Given %!I fill in "new_trans_series" for id "record_input_scheme_pattern_input_1"!
  Given %!I select "nnn" from id like "record_input_scheme_pattern_select_1"!
  Given %!I press "Create"!
end

Given /I collect a "(.*)" with value of "(.*)" from "(.*)"/ do |collection_method_type, amount, payer|
  Given %!I go to ops/collections/new?auto_refresh=&collection_mode=A&record_select_field!
  Given %!I select lookup "#{payer}" for "Payer"!
  Given %!I select lookup "#{collection_method_type}" for "Collection Method Type"!
  Given %!I fill in "SBI" for "Bank Name"!
  Given %!I fill in "1000" for "Cheque / Draft Amount"!
  Given %!I fill in "123" for "Cheque / Draft Number"!
  Given %!I fill in "#{amount}" for "Amount"!
  Given %!I press "Create"!
  Given %!I see a information message "Created"!
end

Given /I check the collection status of "(.*)"/ do |collection_instrument|
  Given %!I go to ops/collection_checks!
  if collection_instrument == 'Bounced'
    Given %!I follow "Bounced"!
    Given %!I fill in "11" for "Bounced Cheque Charges"!
    Given %!I press "Update"!

    elsif collection_instrument == 'Cancel'
     Given %!I follow "Cancel"!
  end
end

Given /I deposit the "(.*)" into bank account/ do |collection_instrument|
  Given %!I go to ops/bank_deposit_slips/new!
  Given %!I select lookup "1234 : 1234" for "Account"!
  Given %!I check "Deposited?"!
  Given %!I press "Create"!
  Given %!I see a Status cell with value "Draft"!
  Given %!I follow "Confirm"!
  Given %!I see a Status cell with value "Created"!
end

Given /I reconcile the statement/ do ||
  Given %!I go to ops/reconciliations/new!
  Given %!I fill in "ref" for "Reconciliation Name"!
  Given %!I select lookup "1234 : 1234" for "Bank Account"!
  Given %!I fill in "1000" for "Beginning Balance"!
  Given %!I fill in "1000" for "Ending Balance"!
  Given %!I check "Reconciled?"!
  Given %!I press "Create"!
  Given %!I see a Status cell with value "Reconciled"!
end

Given /I make the "(.*)" status as "(.*)"/ do |collection_instrument, status|
  Given %!I go to ops/collection_checks!
  Given %!I see a Status cell with value "In clearing"!
  Given %!I follow "#{status}"!
  Given %!I see a Status cell with value "#{status}"!
end


Given /I make a "(.*)" proforma invoice for a customer/ do |invoice_type, sku_table|
  Given %!I go to ops/proforma_invoices/new!
  Given %!I select lookup "SVS Traders" for "Customer"!
  Given %!I fill in "SQ-1234" for "Internal Ref"!
  if invoice_type == "Commercial"
    Given %!I select "Commercial Invoice" from "Invoice Type"!
  else
    Given %!I select "MOD VAT" from "Invoice Type"!
  end
  Given %!I press "Create"!
  Given %!I see a information message "Created"!
  Given %!I see a open detail view!
  sku_table.hashes.each do |hash|
    Given %!I select lookup "#{hash['sku']}" for "SKU"!
    Given %!I set value "#{hash['qty']}" for "Qty"!
    sleep 1
  if invoice_type=="MOD VAT"
    Given %!I fill in "#{hash['qty']}" for "Assessment Qty"!
    Given %!I fill in "1000" for "Assessable Value"!
  end

    Given %!I press "Create"!
    Given %!I see a detail view closed!
  end
  Given "I follow \"Confirm\""
  Given %!I see a Status cell with value "Created"%!
end

