Given /^the following somethings:$/ do |somethings|
  Something.create!(somethings.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) something$/ do |pos|
  visit somethings_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following somethings:$/ do |expected_somethings_table|
  expected_somethings_table.diff!(table_at('table').to_a)
end
