class Life < ApplicationRecord
  enum :gender => {
    :male => "M",
    :female => "F",
  }

  def id_scope
    Life.where(:server_id => server_id, :epoch => epoch)
  end

  def parent_life
    id_scope.find_by(:playerid => parent)
  end

  def eve
    cursor = self
    while cursor && cursor.parent && cursor.parent > 1
      cursor = cursor.parent_life
    end
    return cursor
  end

  def children
    id_scope.where(:parent => playerid)
  end

  def family
    eve.immediate_family
  end

  def immediate_family
    children.map(&:immediate_family).flatten.unshift(self)
  end
end
