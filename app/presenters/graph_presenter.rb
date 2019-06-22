require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'

class GraphPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

  def self.fields
    [
      :playerid,
      :parent,
      :cause,
      :killer,
      :age,
      :name,
      :account_hash,
      :gender,
    ]
  end

  def key
    props[:playerid].to_s
  end

  def parent
    if props[:parent] == -1
      OHOLFamilyTrees::Lifelog::NoParent
    elsif props[:parent]
      props[:parent].to_s
    end
  end

  def killer
    props[:killer] && props[:killer].to_s
  end

  def cause
    props[:cause]
  end

  def age
    props[:age]
  end

  def name
    props[:name] || ('p' + props[:playerid].to_s)
  end

  attr_accessor :highlight

  def player_name
    nil
  end

  def hash
    props[:account_hash]
  end

  def gender
    props[:gender]
  end

  def self.wrap(lives)
    wrapped = OHOLFamilyTrees::History.new
    lives.each do |life|
      wrapped[life[:playerid].to_s] = new(life)
    end
    wrapped
  end

  def self.response(query, killer_query = nil, highlight = [])
    results = wrap(query.select(*fields).all)
    if killer_query
      killers = wrap(killer_query.select(*fields).all)
    else
      killers = {}
    end
    accounts = Set.new
    highlight.each do |playerid|
      if results.has_key?(playerid.to_s)
        results[playerid.to_s].highlight = true
        accounts << results[playerid.to_s].hash
      end
      if killers.has_key?(playerid.to_s)
        killers[playerid.to_s].highlight = true
        accounts << results[playerid.to_s].hash
      end
    end
    accounts.each do |hash|
      results.each do |life|
        if life.hash == hash
          life.highlight = true
        end
      end
      killers.each do |life|
        if life.hash == hash
          life.highlight = true
        end
      end
    end
    OHOLFamilyTrees::Graph.graph(results, killers).output(:dot => String)
  end

  def self.html(query)
    results = query.select(*fields).all
    OHOLFamilyTrees::Graph.html(nil, wrap(results))
  end
end
