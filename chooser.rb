class Chooser
  attr_accessor :choices

  def initialize(choices, seats)
    @choices = choices
    @seats = seats
    @bets = {}
    @assign = {}
  end

  def assign!
    @results = {}
    @choices.each do |data|
      values = data[:choices].map { |a, b| b }
      max    = values.max
      total  = values.sum
      power = 12.0 / total rescue 0 # if they did more or less than 12, normalize the values

      happiness = {}
      data[:choices].each do |a, b|
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
        cost = 1.0 - cost
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

    results = HungarianAlgorithmC.find_pairings(costs)

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