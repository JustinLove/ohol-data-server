class LifeSearch
  def initialize(params)
    @epoch = params[:epoch]&.to_i
    @playerid = params[:playerid]&.to_i
    @query = params[:q]
    if params[:server_id]
      @server_id = params[:server_id].to_i
    else
      server_name = nil
      if params[:server_name]
        server_name = params[:server_name]
      elsif params[:server_short]
        server_name = params[:server_short] + '.onehouronelife.com'
      end
      if server_name
        @server_id = DB[:servers]
          .where(:server_name => server_name)
          .limit(1).pluck(:id).first
      end
    end
    if params[:period]
      @period = ISO8601::Duration.new(params[:period])
    end
    @limit = params[:limit]&.to_i || 20000
  end

  attr_reader :server_id
  attr_reader :epoch
  attr_reader :playerid
  attr_reader :query
  attr_reader :period
  attr_reader :limit

  def lives
    match = {
      :server_id => server_id,
      :epoch => epoch,
      :playerid => playerid,
    }.reject {|k,v| v.nil?}

    result = DB[:lives]
      .where(Sequel.~(:birth_time => nil))
      .order(Sequel.desc(:birth_time)).limit(limit)
      .where(match)
    if query
      #result = result.full_text_search([:name, :account_hash], [query.split.join(' & ')])
      result = result.where(Sequel.ilike(:name, query + '%')).or(Sequel.like(:account_hash, query))
    end
    if period
      last = DB[:lives].max(:birth_time)
      result = result
        .where(Sequel[:birth_time] > last - period.to_seconds)
        #.where(Sequel.~(:birth_time => nil))
    end
    result
  end
end
