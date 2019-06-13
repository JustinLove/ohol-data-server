require 'ohol-family-trees/graph'

class FamilyTreesController < ApplicationController
  def index
    p life_params
    life = Life.find_by!(life_params)
    nodes = GraphPresenter.wrap(life.family)
    render :html => OHOLFamilyTrees::Graph.html(nil, nodes).html_safe
  end

  private

  def life_params
    params.permit(:server_id, :epoch, :playerid)
  end
end
