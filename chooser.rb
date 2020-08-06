# this is the class that you feed in the choices and 
# it spits out the best assignments for overall group happiness
# you initialize it with an array of the users and their choices,
# plus an array of all of the possible choices 
# (which has to be equal to or greater than in count to the users)
# then you can call assign! and it does the assignments and returns
# a hash of the choices and which user was assigned to each and their score
# plus an average score. 
# 1.0 would be everyone got their top choice, 
# 0.0 is nobody got any choice they made
# so, higher is better
class Chooser
  attr_accessor :choices

  # choices array looks like:
  #  data = [
  #  {
  #        :email => "anne@chatterbug.io",
  #      :choices => [
  #          [ "27 - Top Pod / Wall", 4.0 ],
  #          [ "26 - Top Pod / Window", 4.0 ],
  #          [ "25 - Top Pod / Wall", 2.0 ],
  #          [ "24 - Top Pod / Window", 2.0 ]
  #      ]
  #  },
  #  {
  #        :email => "scott@chatterbug.io",
  #      :choices => [
  #          [ "25 - Top Pod / Wall", 10.0 ],
  #          [ "27 - Top Pod / Wall", 2.0 ]
  #      ]
  #  }
  #]
  #
  # seats array looks like:
  # seats = [
  #  "27 - Top Pod / Wall",
  #  "26 - Top Pod / Window",
  #  "25 - Top Pod / Wall", 
  #  "24 - Top Pod / Window",
  #  ...
  #  ]
  def initialize(choices, seats)
    @choices = choices
    @seats = seats
    @bets = {}
    @assign = {}
  end

  # returns something like:
  # [
  #    {
  #      "5 - Back Pod / Wall" => {
  #        :user => "laurena@chatterbug.io",
  #        :score => 1.0
  #      },
  #    "25 - Top Pod / Wall" => {
  #        :user => "scott@chatterbug.io",
  #        :score => 1.0
  #      },
  #   ..
  #   },
  #  1.0  <- average score
  # ]
  def assign!
    @results = {}
    @choices.each do |data|
      values = data[:choices].map { |a, b| b.to_i == 0 ? 1 : b }
      max    = values.max
      total  = values.sum
      power = 12.0 / total rescue 0 # if they did more or less than 12, normalize the values

      happiness = {}
      data[:choices].each do |a, b|
        b = b.to_i == 0 ? 1 : b
        hap = (b / max.to_f)
        happiness[a] = hap
        @bets[a] ||= {}
        @bets[a][data[:email]] = hap
      end

      @results[data[:email]] = {total: total, power: power, happiness: happiness}
    end

    users = @results.keys

    costs = []
    @seats.each_with_index do |seat, x|
      users.each_with_index do |user, y|
        cost = @results[user][:happiness][seat].to_f rescue 0.0
        cost = 1.1 - cost
        costs[x] ||= []
        costs[x][y] = cost
      end
      if users.size < @seats.size
        (@seats.size - users.size).times do |extra|
          y = users.size + extra
          costs[x][y] = 1.5
        end
      end
    end

    m = Munkres.new(costs)
    results = m.find_pairings

    assign = {}
    total_score = 0
    results.each do |row, column|
      seat = @seats[row]
      user = users[column]
      if user
        happ = @results[user][:happiness][seat].to_f rescue 0.0
        assign[seat] = {user: user, score: happ}
        total_score += happ
        puts "#{seat}: #{user} (#{happ})"
      end
    end

    score = total_score / assign.size

    return assign, score
  end

end