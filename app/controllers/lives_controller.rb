class LivesController < ApplicationController
  def index
    query = LifeSearch.new(params).lives
    if stale? :last_modified => query.max(:birth_time), :public => true
      lives = query.select(*PointPresenter.fields).all
      render :json => PointPresenter.wrap(lives)
    end
  end
end
