class PointPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def as_json
    {
      :birth_x => props[:birth_x],
      :birth_y => props[:birth_y],
      :birth_population => props[:birth_population]&.to_i,
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
      :death_population => props[:death_population]&.to_i,
      :death_time => props[:death_time]&.to_i,
      :cause => props[:cause],
      :gender => props[:gender],
    }
  end

  def as_plain
    ([
      int(props[:server_id]),
      int(props[:epoch]),
      int(props[:playerid]),
      int(props[:birth_time]),
      int(props[:birth_x]),
      int(props[:birth_y]),
      int(props[:birth_population]),
      text(props[:gender]),
      int(props[:lineage]),
      int(props[:chain]),
      int(props[:death_time]),
      int(props[:death_x]),
      int(props[:death_y]),
      int(props[:death_population]),
      float(props[:age]),
      cause(props[:cause]),
    ] +
    (props[:name] ? [ name(props[:name]) ] : [])
    ).join(' ')
  end

  def int(x)
    if x.nil?
      'X'
    else
      x.to_i
    end
  end

  def name(x)
    if x
      '"' + x + '"'
    else
      'X'
    end
  end

  def float(x)
    if x.nil?
      'X'
    else
      x.to_f
    end
  end

  def text(x)
    if x.nil?
      'X'
    else
      x
    end
  end

  def cause(x)
    case x
    when nil
      'X'
    when 'hunger'
      'h'
    when 'disconnect'
      'd'
    when 'oldAge'
      'o'
    when /^killer/
      x.sub('killer_', 'k')
    else
      x
    end
  end


  def self.fields
    [
      :birth_x,
      :birth_y,
      :birth_population,
      :birth_time,
      :chain,
      :lineage,
      Sequel[:names][:name],
      :server_id,
      :epoch,
      :playerid,
      :age,
      :death_x,
      :death_y,
      :death_population,
      :death_time,
      :cause,
      :gender,
    ]
  end

  def self.wrap_json(lives)
    lives.map {|life| new(life).as_json}
  end

  def self.wrap_plain(lives)
    lives.map {|life| new(life).as_plain}
  end

  def self.response_json(query)
    lives = query.select(*PointPresenter.fields).all
    {
      :data => PointPresenter.wrap_json(lives),
      #:total => query.unlimited.count, doubles query time
    }
  end

  def self.response_plain(query)
    lives = query.select(*PointPresenter.fields).all
    PointPresenter.wrap_plain(lives).join("\n")
  end
end
