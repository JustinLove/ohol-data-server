class ServersController < ApplicationController
  def index
    query = DB[:servers]
    servers = query.all
    servers.each do |server|
      server.merge!(DB[:lives].where(:server_id => server[:id]).select(Sequel.function(:min, :birth_time), Sequel.function(:max, :birth_time)).first)
    end

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
