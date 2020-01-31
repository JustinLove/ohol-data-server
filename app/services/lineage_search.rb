class LineageSearch
  def initialize(params)
    @unknown_params = params.keys - known_params
    @epoch = params[:epoch]&.to_i
    @playerid = params[:playerid]&.to_i
    @lineage = params[:lineage]&.to_i
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
    if params[:start_time]
      @start_time = Time.at(params[:start_time].to_i)
    end
    if params[:end_time]
      @end_time = Time.at(params[:end_time].to_i)
    end
    if params[:birth_time]
      @start_time = Time.at(params[:birth_time].to_i)
    end
    if params[:death_time]
      @end_time = Time.at(params[:death_time].to_i)
    end
  end

  attr_reader :unknown_params
  attr_reader :server_id
  attr_reader :playerid
  attr_reader :start_time
  attr_reader :end_time
  attr_reader :birth_time
  attr_reader :death_time

  def specified?
    server_id && epoch && lineage
  end

  def example_life
    return @example_life if @example_life
    match = {
      :server_id => server_id,
      :epoch => @epoch,
      :playerid => playerid,
      :lineage => @lineage,
      :birth_time => birth_time,
      :death_time => death_time,
    }.reject {|k,v| v.nil?}

    result = DB[:lives]
      .where(Sequel.~(:birth_time => nil))
      .order(Sequel.desc(:birth_time))
      .where(match)
    if start_time
      result = result
        .where(Sequel[:birth_time] > start_time)
    end
    if end_time
      result = result
        .where(Sequel[:birth_time] <= end_time)
    end
    @example_life = result.select(:lineage, :epoch).first
  end

  def lineage
    @lineage ||= (example_life && example_life[:lineage])
  end

  def epoch
    @epoch ||= (example_life && example_life[:epoch])
  end

  def family
    DB[:lives]
      .where(:server_id => server_id, :epoch => epoch, :lineage => lineage)
      .order(:birth_time)
  end

  def killers
    DB[:lives]
      .where(:server_id => server_id, :epoch => epoch, :playerid => family.where(Sequel.~(:killer => nil)).select(:killer))
      .order(:birth_time)
  end

  def known_params
    [
      :controller,
      :action,
      :epoch,
      :playerid,
      :lineage,
      :server_id,
      :server_name,
      :server_short,
      :start_time,
      :end_time,
      :birth_time,
      :death_time,
      :limit
    ].map(&:to_s)
  end
end
