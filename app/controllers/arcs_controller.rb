class ArcsController < ApplicationController
  def index
    query = DB[:arcs]
    arcs = query.all

    stale = if Rails.configuration.api_cache_headers
      expires_in(expiration_in(10, 5), :public => true)
      stale?(:last_modified => arcs.map {|s| s[:end]}.max, :public => true)
    else
      true
    end

    if stale
      render :json => ArcPresenter.response(arcs)
    end
  end
end
