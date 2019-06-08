class Life < ApplicationRecord
  enum :gender => {
    :male => "M",
    :female => "F",
  }
end
