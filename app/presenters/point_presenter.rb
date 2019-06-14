require 'delegate'

class PointPresenter < SimpleDelegator
  def as_json
    [
      birth_x,
      birth_y,
      birth_time.to_i,
      chain,
      lineage,
    ]
  end

  def self.wrap(lives)
    lives.map {|life| new(life).as_json}
  end
end
