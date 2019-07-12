class ServerPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def as_json
    {
      :id => props[:id],
      :server_name => props[:server_name],
      :min_time => props[:min].to_i,
      :max_time => props[:max].to_i,
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
