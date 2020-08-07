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
  end

  # the assign! method takes the data and does the actual choice assignment
  # -
  # it uses the kuhn-munkres or 'hungarian' algorithm for bipartite matching
  # to try to optimize the "cost" of the member assignment to get the lowest
  # "cost", which in this case corresponds to the highest possible aggregate
  # member rating
  # -
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

    # first we go through and normalize the responses, since not everyone probably followed
    # the directions. we actually don't care what they bet, we only look at it internally
    # to determine relative value of the choices. for example, if all choices are rated
    # equally, then the user is optimally happy with any outcome. if they did one twice as
    # high as the other, then the happiness of the high bet is 1.0 and the half bet is 0.5, etc
    @choices.each do |data|
      values = data[:choices].map { |a, b| b.to_i == 0 ? 1 : b }
      max    = values.max

      # determine the relative happiness for each choice for this user
      happiness = {}
      data[:choices].each do |a, b|
        b = b.to_i == 0 ? 1 : b
        hap = (b / max.to_f)
        happiness[a] = hap
      end

      # record the happinessness
      @results[data[:email]] = happiness
    end

    # debug
    # ap @results

    # get a simple array of the users involved
    users = @results.keys

    # calculate a cost matrix, with x dimension as users and y dimension as choices
    # derive a "cost" by inverting the happiness preference value, so 0.0 is optimal (no cost)
    # and 1.0 is worst (high cost)
    costs = []
    @seats.each_with_index do |seat, x|
      users.each_with_index do |user, y|
        cost = @results[user][seat].to_f rescue 0.0
        cost = 1.1 - cost # make it so there is at least a tiny cost (0.1 is minimum value in this case)
        costs[x] ||= []
        costs[x][y] = cost
      end
      # also pad the matrix's unchoosen choices with impossibly high cost (1.5) 
      # so they are the last possible choice but we have a square matrix
      if users.size < @seats.size
        (@seats.size - users.size).times do |extra|
          y = users.size + extra
          costs[x][y] = 1.5
        end
      end
    end

    # calculate the pairings with the hungarian algo of the cost matrix
    m = Munkres.new(costs)
    results = m.find_pairings

    # now we should have a matrix of the most cost-efficient pairings, convert
    # this back to the original values
    assign = {}
    total_score = 0
    results.each do |row, column|
      seat = @seats[row]
      user = users[column]
      if user
        happ = @results[user][seat].to_f rescue 0.0
        assign[seat] = {user: user, score: happ}
        total_score += happ
        puts "#{seat}: #{user} (#{happ})"
      end
    end

    # determine the average of the scores, so we have a good idea of how happy our users will be overall
    score = total_score / assign.size

    return assign, score
  end

end