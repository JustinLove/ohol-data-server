class LivesController < ApplicationController
  include ActionController::MimeResponds

  def index
    search = LifeSearch.new(params)
    if search.unknown_params.any?
      return render :json => {:error => "unknown parameters", :unknown_params => search.unknown_params}, :status => 400
    end
    query = search.lives

    stale = if Rails.configuration.api_cache_headers
      expires_in(expiration_in(9, 10), :public => true)
      stale?(:last_modified => query.max(:birth_time), :public => true)
    else
      true
    end

    if stale
      respond_to do |format|
        format.text { render :plain => PointPresenter.response_plain(query), :content_type => "text/plain" }
        format.any { render :json => PointPresenter.response_json(query), :content_type => "application/json" }
      end
    end
  end
end
