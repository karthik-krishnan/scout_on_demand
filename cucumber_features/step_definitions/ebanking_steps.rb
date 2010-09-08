#ebanking

Given /^I logged into ebanking as "(.*)"/ do |user|
  logoff
  $browser.goto @host + "ops"
  users = {'maker' => 'green', 'verifier' => 'brown', 'authorizer' => 'black', '2nd authorizer' => 'red', 'authorizer_2' => 'grey'}
  user = users[user]
	$browser.text_field(:name, 'username').value = user
	$browser.text_field(:name, 'password').value = 'test'
	$browser.button(:name, 'submit').click
  assert_successful_response
end

Given /^I logged in management console as "(.*)"/ do |user|
  logoff
  $browser.goto @host + "mc"
	$browser.text_field(:name, 'username').value = user
	$browser.text_field(:name, 'password').value = 'test'
	$browser.button(:name, 'submit').click
  assert_successful_response
end

Given /^I logged into portal as "(.*)"/ do |user|
  $browser.goto "http://ebdemo:2080/sso/login?service=http%3A%2F%2Febdemo%3A2080%2Fportal%2Fc%2Fportal%2Flogin%3Fp_l_id%3D10194"
	$browser.text_field(:name, 'username').value = user
	$browser.text_field(:name, 'password').value = 'test'
	$browser.button(:name, 'submit').click
  assert_successful_response
end

def logoff
    begin
       Given %!I follow "Log Off"!
    rescue
    end
end

When /I follow payment link "(.*)"/ do |link|
  $browser.link(:link,link).click
  assert_successful_response
end

When /I select encripted acct "(.*)"/ do |lookup_item|
  encrypt_for_watir :link, :text, /#{lookup_item}/
  $browser.link(:text, /#{lookup_item}/).click
end

Given /I make a "(.*)" payment for "(.*)" from "(.*)" valued "(.*)" with "(.*)"/ do |payment_type, payee, account, amount, ref|
  if payment_type == "RTGS"
    Given "I go to ops/real_time_gross_settlement_electronic_payments/new"
  elsif  payment_type == "Low Value electronic"
    Given "I go to ops/low_value_electronic_payments/new"
  else
    Given "I go to ops/intra_bank_electronic_payments/new"
  end
  Given "I select \"#{account}\" from \"From Account:\""
  Given "I fill in \"#{amount}\" for \"Amount:\""
  Given "I select \"#{payee}\" from \"Pay To:\""
  Given "I fill in \"#{ref}\" for \"Internal Reference:\""
  Given "I fill in \"ref\" for \"Reference for Payee:\""
  if payment_type == "RTGS"
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_advice_mode_n\""
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_bank_charges_a\""
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_agent_bank_charges_p\""
  end
  Given "I press \"Continue\""
  Given "I press \"Save\""
end

Given /I make a Payment with the following attributes/ do | payment_table |
   payment_table.hashes.each do |hash|
   puts("....#{hash['Payment Type']}")
   if "#{hash['Payment Type']}" == "Low Value Electronic Payment"
    Given "I go to ops/low_value_electronic_payments/new"
  elsif  "#{hash['Payment Type']}" == "RTGS"
    Given "I go to ops/real_time_gross_settlement_electronic_payments/new"
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_advice_mode_n\""
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_bank_charges_a\""
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_agent_bank_charges_p\""
  else
    Given "I go to ops/intra_bank_electronic_payments/new"
  end

  Given "I select \"#{hash['Debit Account']}\" from \"From Account:\""
  puts("while using ....#{hash['Debit Account']}")
  Given "I fill in \"#{hash['Amount']}\" for \"Amount:\""
  Given "I select \"#{hash['Payee']}\" from \"Pay To:\""
  Given "I fill in \"ss\" for \"Internal Reference:\""
  Given "I fill in \"ref\" for \"Reference for Payee:\""
  end
  Given "I press \"Continue\""
  Given "I press \"Save\""
end

Given /I follow workflow "(.*)" of "(.*)"/ do |action, instrument|
  Given "I go to ops/local_payments"
  actions = {'Submit for verification' => 'submit_for_verification', 'Verify' => 'verify', 'Authorize' => 'authorize', 'Release' => 'release'}
  expected_messages = {'Submit to verify' => 'submitted for verification successfully'}
  internal_action = actions[action]

  instruments = {'Domestic Draft' => 'domestic_drafts', 'Low Value Electronic' => 'low_value_electronic_payments', 'RTGS' => 'real_time_gross_settlement_electronic_payments','Intra Bank Electronic' => 'intra_bank_electronic_payments' }
  instrument = instruments[instrument]
  $browser.link(:text, /Amount/).click

  link = $browser.link(:text, /Cancel/)
  link.href =~ /#{instrument}\/([^;\/]+)/
  system_ref = $1
  $browser.link(:url, /#{system_ref}\/edit\?event\=#{internal_action}&type\=workflow/).click
  When "I press \"#{action}\""
  Then "I should see text \"#{expected_messages[action]}\""
  #Given "I follow \"Continue\""
end


Given /I make a draft payment for "(.*)" from "(.*)" valued "(.*)"/ do |payee, account, amount|
  Given "I go to ops/domestic_drafts/new"
  Given "I select \"#{account}\" from \"From Account:\""
  Given "I fill in \"#{amount}\" for \"Amount:\""
  Given "I select \"#{payee}\" from \"Pay To:\""
  Given "I choose radio button with id \"instrument_domestic_draft_collection_mode_b\""
  Given "I select \"Chulia Street\" from \"Pickup Location:\""
  Given "I press \"Continue\""
  Given "I press \"Save\""
end


Given /I make a batch template for "(.*)" from "(.*)"/ do |batch_name, account|
  Given "I go to ops/batch_templates/new"
  Given "I fill in \"#{batch_name}\" for \"Batch Name:\""
  Given "I select \"#{account}\" from \"Offset Account:\""
  Given "I fill in \"test\" for \"Description:\""
  Given "I select \"IPC - Consumer Payments or Collections\" from \"Transaction Type:\""
  Given "I select \"Credit\" from \"Default Transaction Code:\""
  Given "I select \"Self\" from \"Charges borne by:\""
  Given "I press \"Continue\""
  Given "I press \"Save\""
  Given "I follow \"Continue\""
  Given "I follow \"Add New Transaction\""
  Given "I fill in \"emp name\" for \"Name:\""
  Given "I fill in \"111\" for \"Account:\""
  Given "I fill in \"101\" for \"Bank Code:\""
  Given "I fill in \"101\" for \"Branch Code:\""
  Given "I fill in \"1000\" for \"Amount:\""
  Given "I fill in \"101\" for \"Internal Reference:\""
  Given "I fill in \"101\" for \"External Reference:\""
  Given "I press \"Continue\""
  Given "I press \"Save\""
  Given "I follow \"Continue\""
  Given "I follow \"Back to Batch List\""
end

Given /I make a transfer from account no "(.*)" to "(.*)" valued "(.*)"/ do |from_account, to_account, amount|
  Given %!I go to ops/transfers/new!
  Given %!I select "#{from_account}" from "From Account:"!
  Given %!I select "#{to_account}" from "To Account:"!
  Given %!I fill in "#{amount}" for "Amount:"!
  Given %!I press "Continue"!
  Given %!I press "Save"!
end

Given /I make a Intl "(.*)" payment for "(.*)" from "(.*)" valued "(.*)"/ do |payment_type, payee, account, amount|
  if payment_type == "draft"
    Given %!I go to ops/international_drafts/new!
    Given %!I select "United States" from "Country Payable:"!
    Given %!I choose radio button with id "instrument_international_draft_collection_mode_a"!
  else
    Given %!I go to ops/international_electronic_payments/new!
    Given %!I choose radio button with id "instrument_international_electronic_payment_bank_charges_a"!
    Given %!I choose radio button with id "instrument_international_electronic_payment_agent_bank_charges_p"!
  end
  Given %!I select "#{account}" from "From Account:"!
  Given %!I select "USD" from "Payment Currency:"!
  Given %!I fill in "#{amount}" for id "instrument_txn_amount"!
  Given %!I select "#{payee}" from "Pay To:"!
  Given %!I select "Board Rate" from "FX Type:"!
  Given "I press \"Continue\""
  Given "I press \"Save\""
end

Given /I initiate a batch payment "(.*)"/ do |batch_name|
  Given "I go to ops/batch_templates"
#  link = $browser.link(:text, /#{batch_name}/)
#  link.href =~ /([^;\/]+)/
#  system_ref = $1
#  debug_log "value =#{system_ref}"
  $browser.link(:url, /batches\/new\?batch_template_id\=123/).click

  #Given "I follow \"Initiate Batch\""
  Given "I fill in \"ref-1\" for \"Internal Batch Description:\""
  Given "I fill in \"ref\" for \"External Batch Description:\""
  #Given "I set value \"today\" for id \"DatetimeToolbocksInitiatedBatchPickupDateInput\""
  Given "I select \"Immediate\" from \"Priority:\""
  Given "I press \"Continue\""
  Given "I press \"Save\""
  $browser.link(:text, /Continue/).click
end


Given /I follow workflow "(.*)" for "(.*)" with "(.*)"/ do |action, instrument, ref|
  Given "I go to ops/local_payments"
  actions = {'Submit for verification' => 'submit_for_verification', 'Verify' => 'verify', 'Authorize' => 'authorize', 'Release' => 'release'}
  expected_messages = {'Submit to verify' => 'submitted for verification successfully'}
  internal_action = actions[action]

  instruments = {'Domestic Draft' => 'domestic_drafts', 'Low Value' => 'low_value_electronic_payments', 'RTGS' => 'real_time_gross_settlement_electronic_payments','Intra Bank electronic' => 'intra_bank_electronic_payments' }
  instrument = instruments[instrument]
  $browser.link(:text, /Amount/).click

  link = $browser.link(:text, /#{ref}/)
  link.href =~ /#{instrument}\/([^;\/]+)/
  system_ref = $1
  $browser.link(:url, /#{system_ref}\/edit\?event\=#{internal_action}&type\=workflow/).click
  #    When "I press \"Submit for verification\""
  When "I press \"#{action}\""
  Then "I should see text \"#{expected_messages[action]}\""
  #Given "I follow \"Continue\""
end

Given /I follow payment workflow "(.*)" for "(.*)"/ do |action, instrument|
  if instrument == "Batch Payment"
    Given "I go to ops/batches_list"
  elsif instrument == "Transfers"
    Given "I go to ops/transfers_list"
  elsif instrument == "Intl epay" or "Intl Draft"
    Given "I go to ops/international_payments"
  else
  Given "I go to ops/local_payments"
  end
  actions = {'Submit for verification' => 'submit_for_verification', 'Verify' => 'verify', 'Authorize' => 'authorize', 'Submit for authorization' => 'submit_for_authorization', 'Release' => 'release'}

  expected_messages = {'Submit to verify' => 'submitted for verification successfully'}
  internal_action = actions[action]

  instruments = {'Domestic Draft' => 'domestic_drafts', 'Intl epay' => 'international_electronic_payments', 'Intl Draft' => 'international_drafts', 'Transfers' => 'transfers', 'Batch Payment' => 'batches'}
  instrument = instruments[instrument]
  $browser.link(:text, /Amount/).click
  link = $browser.link(:text, /Cancel/)
  link.href =~ /#{instrument}\/([^\/\/]+)/
  system_ref = $1
  puts("sys ref...#{system_ref}")
  if instrument == "batches"
    $browser.link(:url, /#{system_ref}\/batch_details\?event\=#{internal_action}&type\=workflow/).click
  else
    $browser.link(:url, /#{system_ref}\/edit\?event\=#{internal_action}&type\=workflow/).click
  end
  When "I press \"#{action}\""
  Then "I should see text \"#{expected_messages[action]}\""
 end

Then /I should have link to "(.*)" for "(.*)" with "(.*)"/  do |action, instrument, ref|
  actions = {'Submit to verify' => 'submit_for_verification', 'Verify' => 'verify', 'Authorize' => 'authorize', 'Release' => 'release'}
  expected_messages = {'Submit to verify' => 'submitted for verification successfully','Verify' => 'verify', 'Authorize' => 'authorize', 'Release' => 'release'}
  internal_action = actions[action]

  instruments = {'Domestic Draft' => 'domestic_drafts', 'Low Value' => 'low_value_electronic_payments'}
  instrument = instruments[instrument]
  $browser.link(:text, /Amount/).click
  link = $browser.link(:text, /#{ref}/)
  link.href =~ /#{instrument}\/([^;\/]+)/
  system_ref = $1
  lambda {
    $browser.link(:url, /#{system_ref}\/edit\?event\=#{internal_action}&type\=workflow/).assert
  }.should_not raise_error

end

Then /I should have payment link to "(.*)" for "(.*)"/  do |action, instrument|
  actions = {'Submit to verify' => 'submit_for_verification', 'Verify' => 'verify', 'Authorize' => 'authorize', 'Release' => 'release'}
  expected_messages = {'Submit to verify' => 'submitted for verification successfully','Verify' => 'verify', 'Authorize' => 'authorize', 'Release' => 'release'}
  internal_action = actions[action]

  instruments = {'Domestic Draft' => 'domestic_drafts', 'Low Value' => 'low_value_electronic_payments'}
  instrument = instruments[instrument]
  $browser.link(:text, /Amount/).click
  link = $browser.link(:text)
  link.href =~ /#{instrument}\/([^;\/]+)/
  system_ref = $1

  lambda {
    $browser.link(:url, /#{system_ref}\/edit\?event\=#{internal_action}&type\=workflow/).assert
  }.should_not raise_error

end


Then /the payment status should be "(.*)"/ do |status|
  xpath_expression = "//td[contains(@class, 'Status')][contains(text(), '#{status}')]"
end


Then /I should have link to initiate batch for "(.*)"/  do |text|
  $browser.text.should include_text(text)
end

Then /I should have link in outgoing payments with "(.*)"/  do |text|
  Given "I go to ops/local_payments?filter=payments_sent_today"
  $browser.text.should include_text(text)
end

Then /I should have link in outgoing payments for "(.*)"/  do |text|
  Given "I go to ops/local_payments?filter=payments_sent_today"
  $browser.text.should include_text(text)
end

Given /I add a "(.*)" payee "(.*)"/ do |payee_type, payee_name|
    if payee_type == "domestic"
  Given %!I go to ops/domestic_payees/new!
  Given %!I fill in "#{payee_name}" for "Payee Name:"!
  Given %!I fill in "#{payee_name}" for "Payee Nick Name:"!
  Given %!I check "Save as Draft Payee:"!
  Given %!I fill in "address1" for "Payee Address:"!
  Given %!I fill in "Singapore" for "Payee City:"!
  Given %!I fill in "43210" for "Payee Postal Code:"!
    else
  Given %!I go to ops/personal_international_payees/new!
  Given %!I fill in "#{payee_name}" for "Beneficiary Name:"!
  Given %!I fill in "#{payee_name}" for "Beneficiary Nick Name:"!
  Given %!I select "SWIFT" from "Beneficiary Bank Identifier Type:"!
  Given %!I fill in "scb001" for "Beneficiary Bank Identifier:"!
  Given %!I check "Save as Draft Beneficiary:"!
  Given %!I fill in "address1" for "Beneficiary Address:"!
  Given %!I fill in "London" for "Beneficiary City:"!
  Given %!I fill in "543210" for "Beneficiary Postal Code:"!
  Given %!I select "United Kingdom" from "Beneficiary Country:"!
    end
  Given %!I press "Continue"!
  Given %!"I press "Save"!
end

When /I follow payee workflow "(.*)" for "(.*)"/ do |action, payee_type|
  Given %!I go to ops/domestic_payees!
  Given %!"I follow "#{action}"!
  if action == 'Activate'
    Given %!I see a information message "Activate Payee?"!
    Given %!I fill in "12345" for id like "activation_pin"!
  end
  Given %!I press "#{action}"!
end

Given /I add "(.*)" into "(.*)" bank list/ do |bank_name, bank_type|
  Given %!I go to ops/personal_international_banks/new!
  Given %!I fill in "#{bank_name}" for "Bank Name:"!
  Given %!I fill in "address1" for "Bank Address:"!
  Given %!I fill in "London" for "Bank City:"!
  Given %!I fill in "43210" for "Bank Postal Code:"!
  Given %!I select "United Kingdom" from "Country:"!
  Given %!I select "SWIFT" from "Primary Bank Identifier Type:"!
  Given %!I fill in "LOY3450" for "Primary Bank Identifier:"!
  Given %!I press "Continue"!
  Given %!"I press "Save"!
end

Given /I add a corporate "(.*)" with id "(.*)" and package "(.*)"/ do |corporate_name, id, package_name|
  Given %!I go to mc/companies/new!
  Given %!I fill in "#{id}" for "Corporate id"!
  Given %!I fill in "#{corporate_name}" for "Corporate Name"!
  Given %!I select "#{package_name}" from "Package"!
  Given %!I select "SGD" from "Preferred Currency"!
  #Given %!I choose "Active"!
  Given %!I fill in "address 1" for "Street Address"!
  Given %!I fill in "Singapore" for "City Name"!
  Given %!I fill in "432101" for "Postal Code"!
  Given %!"I press "Create"!
end

Given /I make a payment request for "(.*)" from "(.*)" valued "(.*)" in portal/ do |payee, account, amount|
  Given "I go to portal/user/brown/payments"
  Given "I go to portal/user/brown/payments?p_p_id=domestic_payments_WAR_ebanking_portlets&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_count=1&_domestic_payments_WAR_ebanking_portlets_railsRoute=%2Fdomestic_drafts%2Fnew"
  Given "I select \"#{account}\" from \"From Account:\""
  Given "I fill in \"#{amount}\" for \"Amount:\""
  Given "I select \"#{payee}\" from \"Pay To:\""
  Given "I choose radio button with id \"instrument_domestic_draft_collection_mode_b\""
  Given "I select \"Chulia Street\" from \"Pickup Location:\""
  Given "I press \"Continue\""
  Given "I press \"Save\""
end

Given /I follow payment workflow "(.*)" in portal for "(.*)"/ do |action, instrument|
  if instrument == "Batch Payment"
    Given "I go to ops/batches_list"
  elsif instrument == "Transfer"
    Given "I go to ops/transfers_list"
  elsif instrument == "Intl epay"
    Given "I go to ops/international_payments"
  else
  Given "I go to portal/user/brown/payments"
  end
  actions = {'Submit for verification' => 'submit_for_verification', 'Verify' => 'verify', 'Authorize' => 'authorize', 'Submit for authorization' => 'submit_for_ authorization', 'Release' => 'release'}
  expected_messages = {'Submit to verify' => 'submitted for verification successfully'}
  internal_action = actions[action]

  instruments = {'Domestic Draft' => 'domestic_drafts', 'Low Value' => 'low_value_electronic_payments', 'Transfers' => 'transfers', 'Authorize' => 'authorize', 'Release' => 'release'}
  instrument = instruments[instrument]
  $browser.link(:text, /Amount/).click
  link = $browser.link(:text, /Cancel/)
  link.href =~ /#{instrument}\/([^\/\/]+)/
  system_ref = $1
  puts("sysy ref...#{system_ref}")
  $browser.link(:url, /#{system_ref}\/edit\?event\=#{internal_action}&type\=workflow/).click

  #When "I follow \"#{action}\""
  When "I press \"#{action}\""
  Then "I should see text \"#{expected_messages[action]}\""
 end

Given /I add a new package "(.*)" with id "(.*)"/ do |package_name, package_id|
  Given %!I go to mc/default_business_classes/new!
  Given %!I fill in "#{package_id}" for "Package Id"!
  Given %!I fill in "#{package_name}" for "Package name"!
  Given %!I fill in "10000" for "Daily limit amount"!
  Given %!I select "active" from id like "record_param_status_"!
  Given %!I check a box with id like"record_verification_req_"!
  Given %!I check a box with id like"record_signature_req_"!
  Given %!I check a box with id like"record_fixed_signature_"!
  Given %!I select "1" from id like "record_signature_tally_"!
  Given %!"I press "Create"!
end

Given /I add a new product type "(.*)" with name "(.*)"/ do |product_type, product_type_name|
  Given %!I go to mc/product_types/new!
  Given %!I fill in "#{product_type}" for "Product Type"!
  Given %!I fill in "#{product_type_name}" for "Product Type Name"!
  Given %!I select "SGD" from "Currency"!
  Given %!I choose radio button with id "record_product_type_status_"!
  Given %!"I press "Create"!
end

Given /I add a new product sub type "(.*)" with name "(.*)"/ do |product_sub_type_id, product_sub_type_name|
  Given %!I go to mc/product_sub_types/new!
  Given %!I fill in "#{product_sub_type_id}" for "Product sub type id"!
  Given %!I fill in "#{product_sub_type_name}" for "Product Sub Type Name"!
  Given %!I select "Loan Accounts" from "Product Type"!
  Given %!I select "SGD" from "Currency"!
  Given %!I choose radio button with id "record_product_sub_type_status_"!
  Given %!I fill in "30" for "Register Days"!
  Given %!"I press "Create"!
end

Given /I add a new business account "(.*)"/ do |account_number|
  Given %!I go to mc/business_accounts/new!
  Given %!I fill in "#{account_number}" for "Account number"!
  Given %!I select "SGD" from "Currency"!
  Given %!I select "Basic Savings" from "Product"!
  Given %!"I press "Create"!
end

Given /I make a "(.*)" template for "(.*)" payment/ do |template_type, instrument|
  if template_type == "Restrictive" and instrument == "Low Value Electronic"
      Given %!I go to ops/real_time_gross_settlement_electronic_payment_templates/new?instrument[template_type]=R!
      Given %!I check a box with id "instrument_low_value_electronic_payment_template_debit_account_num_locked"!
      Given %!I check a box with id "instrument_low_value_electronic_payment_template_payee_id_locked"!
      Given %!I check a box with id "instrument_low_value_electronic_payment_template_internal_ref_required"!

  elsif template_type == "Restrictive" and instrument == "RTGS"
      Given %!I go to ops/low_value_electronic_payment_templates/new?instrument[template_type]=R!
      Given %!I check a box with id like"instrument_real_time_gross_settlement_electronic_payment_template_debit_account_num_locked"!
      Given %!I check a box with id like"instrument_real_time_gross_settlement_electronic_payment_template_payee_id_locked"!
      Given %!I check a box with id like"instrument_real_time_gross_settlement_electronic_payment_template_internal_ref_required"!

  elsif template_type == "Convenience" and instrument == "RTGS"
      Given "I go to ops/real_time_gross_settlement_electronic_payment_templates/new?instrument[template_type]=C"

  else template_type == "Convenience" and instrument == "Low Value Electronic"
      Given "I go to ops/low_value_electronic_payment_templates/new"
  end

  Given %!I fill in "premier_payment" for "Template Name:"!
  Given %!I fill in "Sales commisssion" for "Description:"!
  Given %!I select "Txxxxxxxx044" from "From Account:"!
  Given %!I select "Premier group-123123124" from "Pay To:"!
  Given %!I fill in "ref" for "Reference for Payee:"!

  if instrument == "RTGS"
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_template_bank_charges_a\""
    Given "I choose radio button with id \"instrument_real_time_gross_settlement_electronic_payment_template_agent_bank_charges_p\""
  end
  Given "I press \"Continue\""
  Given "I press \"Save\""
end

Then /^I should see the audit trail information of "(.*)"/  do |instrument, result_table|
  Given "I go to ops/local_payments"
  $browser.link(:text, /Amount/).click
  link = $browser.link(:text, /Cancel/)
  instruments = {'Domestic Draft' => 'domestic_drafts', 'Low Value Electronic' => 'low_value_electronic_payments', 'RTGS' => 'real_time_gross_settlement_electronic_payments','Intra Bank Electronic' => 'intra_bank_electronic_payments' }
  instrument = instruments[instrument]
  link.href =~ /#{instrument}\/([^\/\/]+)/
  system_ref = $1
  $browser.link(:url, /#{system_ref}/).click

    result_table.hashes.each do |hash|
  $browser.text.should include_text("#{hash['Activity']}")
  $browser.text.should include_text("#{hash['User_Name']}")
    end
end
