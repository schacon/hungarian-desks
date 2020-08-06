require './env'
require './chooser'

seats = [
  "27 - Top Pod / Wall",
  "26 - Top Pod / Window",
  "25 - Top Pod / Wall", 
  "24 - Top Pod / Window",
  "1 - Front Room",
  "3 - Front Room",
  "6 - Back Pod / Hall",
  "15 - Running Table / Window",
  "23 - Kitchen Pod / Window",
  "5 - Back Pod / Wall",
  "2 - Front Room",
  "4 - Back Pod / Hall",
  "1 - Back Pod / Hall",
  "2 - Back Pod / Hall",
  "3 - Back Pod / Hall",
  "5 - Back Pod / Hall",
  "6 - Back Pod / Hall",
  "7 - Back Pod / Hall",
  "8 - Back Pod / Hall",
  "9 - Back Pod / Hall",
  "10 - Back Pod / Hall",
  "114 - Back Pod / Hall",
  "124 - Back Pod / Hall",
  "134 - Back Pod / Hall",
  "144 - Back Pod / Hall",
  "147 - Back Pod / Hall",
]

data = [
  {
        :email => "anne@chatterbug.io",
      :choices => [
          [ "27 - Top Pod / Wall", 4.0 ],
          [ "26 - Top Pod / Window", 4.0 ],
          [ "25 - Top Pod / Wall", 2.0 ],
          [ "24 - Top Pod / Window", 2.0 ]
      ]
  },
  {
        :email => "scott@chatterbug.io",
      :choices => [
          [ "25 - Top Pod / Wall", 10.0 ],
          [ "27 - Top Pod / Wall", 2.0 ]
      ]
  }
]

ap Chooser.new(data, seats).assign!