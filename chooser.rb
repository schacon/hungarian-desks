class Chooser
  attr_accessor :choices

  def initialize(choices, seats)
    @choices = choices
    @seats = seats
    @bets = {}
    @assign = {}
  end

  # find the best seat in the house for everyone
  # - for each person
  #   - normalize voting (too high or low)
  #   - determine happiness ranking for each seat
  # - for each seat
  #   - find person most happy with it who is unopposed
  # - each seat
  #   - find person most happy from contested
  # go through every seat and see who bid highest
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

    ap @results
    ap @bets

    # assign happy, totally unopposed seats
    @bets.each do |seat, bids|
      if (bids.size == 1) && (bids.first[1] >=  0.8)
        email = bids.first[0]
        @assign[email] ||= {}
        @assign[email][:result] = seat
        @assign[email][:result_score] = bids.first[0]

        # remove seat
        @bets.delete(seat)
        # remove user's other bids
        @bets.each { |seat, bids| bids.delete(email) } 
      end
    end

    ap @assign
    ap @bets

  end
end