require 'delegate'
require 'ohol-family-trees/lifelog'
require 'ohol-family-trees/history'

class GraphPresenter < SimpleDelegator
  def key
    playerid.to_s
  end

  def parent
    if super == -1
      OHOLFamilyTrees::Lifelog::NoParent
    elsif super
      super.to_s
    end
  end

  def killer
    super && super.to_s
  end

  def name
    super || ('p' + playerid.to_s)
  end

  def highlight
    false
  end

  def player_name
    nil
  end

  def hash
    account_hash
  end

  def gender
    if male?
      'M'
    elsif female?
      'F'
    else
      super
    end
  end

  def self.wrap(lives)
    wrapped = OHOLFamilyTrees::History.new
    lives.each do |life|
      wrapped[life.playerid.to_s] = new(life)
    end
    wrapped
  end
end
