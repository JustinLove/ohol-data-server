require 'ohol-family-trees/graph'

class FamilyTreesController < ApplicationController
  def index
    search = LineageSearch.new(params)
    #render :html => GraphPresenter.html(family).html_safe

    render :plain => GraphPresenter.response(search.family, search.killers, [search.playerid].compact)
  end

  private

  def life_params
    params.permit(
      :server_id,
      :epoch,
      :playerid,
      :lineage,
      :server_name,
      :server_short,
      :start_time,
      :end_time,
      :birth_time,
      :death_time )
  end
end
