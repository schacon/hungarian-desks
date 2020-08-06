require './env'
require './chooser'

at_key = ENV["AIRTABLE_KEY"]
base_id = "appKsX9MFToijWQx0"

client = Airtable::Client.new(at_key)
choices = client.table(base_id, "Choices")
desks = client.table(base_id, "Desks")

def desk(id)
  @dnames[id]
end

@dlist = {}
@dnames = {}
desks.all.each do |desk|
  number = desk.name.split("-").first.to_i
  @dlist[desk.name] = {id: desk.id, number: number}
  @dnames[desk.id] = desk.name
end

# construct the user choice data array from airtable choices
data = []
ulist = {}
choices.all.each do |choice|
  next if choice.desker_type != "Perma-desk"

  ap choice

  user_choices = {}
  email = choice.email
  ulist[choice.email] = {id: choice.id, email: email}
  user_choices[:email] = choice.email
  user_choices[:choices] = []
  user_choices[:choices] << [desk(choice.first_choice.first), choice.first_choice_weight.to_f] if choice.first_choice
  user_choices[:choices] << [desk(choice.second_choice.first), choice.second_choice_weight.to_f] if choice.second_choice
  user_choices[:choices] << [desk(choice.third_choice.first), choice.third_choice_weight.to_f] if choice.third_choice
  user_choices[:choices] << [desk(choice.fourth_choice.first), choice.fourth_choice_weight.to_f] if choice.fourth_choice
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
  ap desk_number = @dlist[desk_name][:number]
  ap user_id = ulist[user_data[:user]][:id]
  ap choice = choices.find(user_id)
  choice.result_desk = desk_number
  choice.save
  ap choices.update(choice)
  exit
end