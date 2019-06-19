class MonumentsController < ApplicationController
  def index
    expires_in expiration_in(8, 5), :public => true
    query = MonumentSearch.new(params).monuments
    monuments = query.select(*MonumentPresenter.fields).all
    if stale? :last_modified => monuments.map {|m| m[:date]}.max, :public => true
      render :json => MonumentPresenter.wrap(monuments)
    end
  end
end
