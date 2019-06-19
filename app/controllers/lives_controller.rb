class LivesController < ApplicationController
  def index
    query = LifeSearch.new(params).lives

    stale = if Rails.configuration.api_cache_headers
      expires_in(expiration_in(9, 10), :public => true)
      stale?(:last_modified => query.max(:birth_time), :public => true)
    else
      true
    end

    if stale
      lives = query.select(*PointPresenter.fields).all
      render :json => PointPresenter.wrap(lives)
    end
  end
end
