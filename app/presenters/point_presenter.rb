class PointPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def as_json
    {
      :birth_x => props[:birth_x],
      :birth_y => props[:birth_y],
      :birth_time => props[:birth_time]&.to_i,
      :chain => props[:chain],
      :lineage => props[:lineage],
    }
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

  def self.response(query)
    lives = query.select(*PointPresenter.fields).all
    {
      :data => PointPresenter.wrap(lives),
      :total => query.unlimited.count,
    }
  end
end
