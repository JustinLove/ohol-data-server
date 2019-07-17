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
      :name => props[:name],
      :server_id => props[:server_id],
      :epoch => props[:epoch],
      :playerid => props[:playerid],
      :age => props[:age],
      :death_x => props[:death_x],
      :death_y => props[:death_y],
      :death_time => props[:death_time]&.to_i,
      :cause => props[:cause],
    }
  end

  def self.fields
    [
      :birth_x,
      :birth_y,
      :birth_time,
      :chain,
      :lineage,
      :name,
      :server_id,
      :epoch,
      :playerid,
      :age,
      :death_x,
      :death_y,
      :death_time,
      :cause,
    ]
  end

  def self.wrap(lives)
    lives.map {|life| new(life).as_json}
  end

  def self.response(query)
    lives = query.select(*PointPresenter.fields).all
    {
      :data => PointPresenter.wrap(lives),
      #:total => query.unlimited.count, doubles query time
    }
  end
end
