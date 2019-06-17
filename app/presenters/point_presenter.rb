class PointPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def as_json
    [
      props[:birth_x],
      props[:birth_y],
      props[:birth_time]&.to_i,
      props[:chain],
      props[:lineage],
    ]
  end

  def self.fields
    [
      :birth_x,
      :birth_y,
      :birth_time,
      :chain,
      :lineage,
    ]
  end

  def self.wrap(lives)
    lives.map {|life| new(life).as_json}
  end
end
