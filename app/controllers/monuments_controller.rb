class MonumentsController < ApplicationController
  def index
    lives = MonumentSearch.new(params).monuments.select(*MonumentPresenter.fields).all
    render :json => MonumentPresenter.wrap(lives)
  end
end
