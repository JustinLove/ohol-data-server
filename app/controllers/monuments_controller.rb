class MonumentsController < ApplicationController
  def index
    query = MonumentSearch.new(params).monuments
    monuments = query.select(*MonumentPresenter.fields).all

    stale = if Rails.configuration.api_cache_headers
      expires_in expiration_in(8, 5), :public => true
      stale?(:last_modified => monuments.map {|m| m[:date]}.max, :public => true)
    else
      true
    end

    if stale
      render :json => MonumentPresenter.wrap(monuments)
    end
  end
end
