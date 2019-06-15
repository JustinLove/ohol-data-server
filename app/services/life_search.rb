class LifeSearch
  def initialize(params)
    @epoch = params[:epoch]&.to_i
    @playerid = params[:playerid]&.to_i
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
  end

  attr_reader :server_id
  attr_reader :epoch
  attr_reader :playerid
  attr_reader :period

  def lives
    match = {
      :server_id => server_id,
      :epoch => epoch,
      :playerid => playerid,
    }.reject {|k,v| v.nil?}

    result = DB[:lives]
      .order(Sequel.desc(:birth_time)).limit(100000)
      .where(match)
    if period
      result = result
        .where(Sequel.~(:birth_time => nil))
        .where(Sequel[:birth_time] > Time.now - period.to_seconds)
    end
    result.all
  end
end
