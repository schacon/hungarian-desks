require './env'
require './chooser'

Airrecord.api_key = ENV["AIRTABLE_KEY"]

class Choice < Airrecord::Table
  self.base_key = "appKsX9MFToijWQx0"
  self.table_name = "Choices"
end

class Desk < Airrecord::Table
  self.base_key = "appKsX9MFToijWQx0"
  self.table_name = "Desks"
end

def desk(id)
  @dnames[id]
end

@dlist = {}
@dnames = {}
Desk.all.each do |desk|
  number = desk["Name"].split("-").first.to_i
  @dlist[desk["Name"]] = {id: desk.id, number: number}
  @dnames[desk.id] = desk["Name"]
end

# construct the user choice data array from airtable choices
data = []
ulist = {}
Choice.all.each do |choice|
  next if choice["Desker Type"] != "Perma-desk"

  ap choice

  user_choices = {}
  email = choice["Email"]
  ulist[email] = {id: choice.id, email: email}
  user_choices[:email] = email
  user_choices[:choices] = []
  user_choices[:choices] << [desk(choice["First Choice"].first), choice["First Choice Weight]"].to_f] if choice["First Choice"]
  user_choices[:choices] << [desk(choice["Second Choice"].first), choice["Second Choice Weight"].to_f] if choice["Second Choice"]
  user_choices[:choices] << [desk(choice["Third Choice"].first), choice["Third Choice Weight"].to_f] if choice["Third Choice"]
  user_choices[:choices] << [desk(choice["Fourth Choice"].first), choice["Fourth Choice Weight"].to_f] if choice["Fourth Choice"]
  data << user_choices
end

#ap data
#ap ulist

# construct a list of the possible choices
seats = @dlist.keys

# do the assignment
assigns, score = Chooser.new(data, seats).assign!

# show the results
ap assigns
puts "SCORE: #{score}"

assigns.each do |desk_name, user_data|
  ap desk_id = @dlist[desk_name][:id]
  ap desk = Desk.find(desk_id)
  ap user_id = ulist[user_data[:user]][:id]
  ap choice = Choice.find(user_id)
  choice["Result Desk"] = [desk_id]
  choice["Result Score"] = user_data[:score]
  ap choice.save
end