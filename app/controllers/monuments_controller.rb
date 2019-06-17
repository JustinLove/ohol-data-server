class MonumentsController < ApplicationController
  def index
    query = MonumentSearch.new(params).monuments
    monuments = query.select(*MonumentPresenter.fields).all
    if stale? :last_modified => monuments.map {|m| m[:date]}.max, :public => true
      render :json => MonumentPresenter.wrap(monuments)
    end
  end
end
