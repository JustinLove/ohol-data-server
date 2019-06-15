class LivesController < ApplicationController
  def index
    lives = LifeSearch.new(params).lives
    render :json => PointPresenter.wrap(lives)
  end
end
