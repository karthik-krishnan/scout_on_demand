Given /^the following credit_terms:$/ do |credit_terms|
  CreditTerm.create!(credit_terms.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) credit_term$/ do |pos|
  visit credit_terms_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following credit_terms:$/ do |expected_credit_terms_table|
  expected_credit_terms_table.diff!(table_at('table').to_a)
end
