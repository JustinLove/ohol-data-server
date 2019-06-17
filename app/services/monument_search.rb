class MonumentSearch
  def initialize(params)
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
    @limit = params[:limit]&.to_i || 1000
  end

  attr_reader :server_id
  attr_reader :period
  attr_reader :limit

  def monuments
    match = {
      :server_id => server_id,
    }.reject {|k,v| v.nil?}

    result = DB[:monuments]
      .order(Sequel.desc(:date)).limit(limit)
      .where(match)
    if period
      result = result
        .where(Sequel[:birth_time] > Time.now - period.to_seconds)
    end
    result
  end
end
