class ArcPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def as_json
    {
      :id => props[:id],
      :server_id => props[:server_id],
      :start => props[:start].to_i,
      :end => props[:end].to_i,
      :seed => props[:seed],
    }
  end

  def self.wrap(records)
    records.map {|x| new(x).as_json}
  end

  def self.response(records)
    {
      :data => wrap(records),
      #:total => query.unlimited.count,
    }
  end
end
