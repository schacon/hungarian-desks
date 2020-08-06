require './env'

at_key = ENV["AIRTABLE_KEY"]
base_id = "appKsX9MFToijWQx0"

client = Airtable::Client.new(at_key)
table = client.table(base_id, "Choices")

table.all.each do |choice|
  ap choice
end