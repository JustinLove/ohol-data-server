class MonumentPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def as_json
    {
      :x => props[:x],
      :y => props[:y],
      :date => props[:date]&.to_i,
    }
  end

  def self.fields
    [
      :x,
      :y,
      :date,
    ]
  end

  def self.wrap(records)
    records.map {|x| new(x).as_json}
  end

  def self.response(query)
    monuments = query.select(*MonumentPresenter.fields).all
    {
      :data => MonumentPresenter.wrap(monuments),
      :total => query.unlimited.count,
    }
  end
end
