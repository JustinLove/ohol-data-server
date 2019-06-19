class ServersController < ApplicationController
  def index
    query = DB[:servers]

    if Rails.configuration.api_cache_headers
      expires_in 24*60*60, :public => true
    end

    render :json => ServerPresenter.response(query)
  end
end
