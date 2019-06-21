require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'

class GraphPresenter
  def initialize(props)
    @props = props
  end

  attr_reader :props

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

  def highlight
    false
  end

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
end
