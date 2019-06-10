class PointsController < ApplicationController
  def index
    render :json => PointPresenter.wrap(
      Life.where(:birth_time => ((Date.today - 2)..(Date.today))))
  end
end
