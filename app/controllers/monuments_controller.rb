class MonumentsController < ApplicationController
  def index
    query = MonumentSearch.new(params).monuments

    stale = if Rails.configuration.api_cache_headers
      expires_in expiration_in(8, 5), :public => true
      stale?(:last_modified => query.max(:date), :public => true)
    else
      true
    end

    if stale
      render :json => MonumentPresenter.response(query)
    end
  end
end
