require './env'
require './chooser'

at_key = ENV["AIRTABLE_KEY"]
base_id = "appKsX9MFToijWQx0"

client = Airtable::Client.new(at_key)
choices = client.table(base_id, "Choices")
desks = client.table(base_id, "Desks")

def desk(id)
  @dlist[id][:name]
end

@dlist = {}
desks.all.each do |desk|
  number = desk.name.split("-").first.to_i
  @dlist[desk.id] = {name: desk.name, number: number}
end
ap @dlist

data = []
ulist = {}
choices.all.each do |choice|
  next if choice.desker_type != "Perma-desk"

  user_choices = {}
  email = choice.email
  ulist[choice.id] = {email: email}
  user_choices[:email] = email
  user_choices[:choices] = []
  user_choices[:choices] << [desk(choice.first_choice.first), choice.first_choice_weight.to_f] if choice.first_choice
  user_choices[:choices] << [desk(choice.second_choice.first), choice.second_choice_weight.to_f] if choice.second_choice
  user_choices[:choices] << [desk(choice.third_choice.first), choice.third_choice_weight.to_f] if choice.third_choice
  user_choices[:choices] << [desk(choice.fourth_choice.first), choice.fourth_choice_weight.to_f] if choice.fourth_choice
  data << user_choices
end

ap data
ap ulist

ap seats = @dlist.to_a.map { |a| a[1][:name] }
ap Chooser.new(data, seats).assign!