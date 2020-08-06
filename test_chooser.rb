require './env'
require './chooser'

seats = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
data = [
  { email: 'anne', 
    choices: [[1, 5], [2, 5], [3, 1], [4, 1]] # heavily like two
  },
  { email: 'scott', 
    choices: [[1, 8], [2, 2], [3, 1], [4, 1]] # heavily like one
  },
  { email: 'tom', 
    choices: [[2, 4], [3, 4], [4, 4], [1, 4]] # like all the same
  },
  { email: 'liz', 
    choices: [[5, 5], [8, 5], [3, 1], [1, 1]] # heavily like two
  },
  { email: 'russ', 
    choices: [[4, 12]] # only chooses one 
  },
  { email: 'inda', 
    choices: [[4, 10], [8, 5], [2, 18], [1, 4]] # bets too much 
  },
  { email: 'ben', 
    choices: [[4, 1], [6, 1], [8, 1]] # bets too little 
  },
  { email: 'nick', 
    choices: [] # bets none
  },
]

Chooser.new(data, seats).assign!