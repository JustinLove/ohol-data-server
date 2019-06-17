class LivesController < ApplicationController
  def index
    lives = LifeSearch.new(params).lives.select(*PointPresenter.fields).all
    render :json => PointPresenter.wrap(lives)
  end
end
