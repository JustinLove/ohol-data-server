class LivesController < ApplicationController
  def index
    render :json => PointPresenter.wrap(
      Life.where(:server_id => 17, :birth_time => ((Date.today - 2)..(Date.today))))
  end
end
