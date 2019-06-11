class FamilyTreesController < ApplicationController
  def index
    p life_params
    life = Life.find_by!(life_params)
    p 'v' * 20
    p life.family.map(&:nil?)
    p '^' * 20
    render :json => PointPresenter.wrap(life.family)
  end

  private

  def life_params
    params.permit(:server_id, :epoch, :playerid)
  end
end
