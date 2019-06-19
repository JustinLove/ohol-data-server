class ServerPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def as_json
    props
  end

  def self.fields
    [
      :id,
      :server_name,
    ]
  end

  def self.wrap(records)
    records.map {|x| new(x).as_json}
  end

  def self.response(query)
    records = query.select(*fields).all
    {
      :data => wrap(records),
      :total => query.unlimited.count,
    }
  end
end
