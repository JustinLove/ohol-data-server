require 'ohol-family-trees/graph'

class FamilyTreesController < ApplicationController
  def index
    lineage = DB[:lives]
      .where(:server_id => params[:server_id], :epoch => params[:epoch], :playerid => params[:playerid])
      .limit(1).pluck(:lineage).first
    family = DB[:lives]
      .where(:server_id => params[:server_id], :epoch => params[:epoch], :lineage => lineage)
      .order(:birth_time)
    killers = DB[:lives]
      .where(:server_id => params[:server_id], :epoch => params[:epoch], :playerid => family.where(Sequel.~(:killer => nil)).select(:killer))
      .order(:birth_time)
    #render :html => GraphPresenter.html(family).html_safe

    render :plain => GraphPresenter.response(family, killers, [params[:playerid]])
  end

  private

  def life_params
    params.permit(:server_id, :epoch, :playerid)
  end
end
