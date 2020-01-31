class ServersController < ApplicationController
  def index
    servers = ServerList.new.servers

    stale = if Rails.configuration.api_cache_headers
      expires_in(expiration_in(9, 10), :public => true)
      stale?(:last_modified => servers.map {|s| s[:max]}.max, :public => true)
    else
      true
    end

    if stale
      render :json => ServerPresenter.response(servers)
    end
  end
end
