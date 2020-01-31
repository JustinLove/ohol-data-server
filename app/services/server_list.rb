class ServerList
  def servers
    query = DB[:servers]
    result = query.all
    result.each do |server|
      server.merge!(DB[:lives].where(:server_id => server[:id]).select(Sequel.function(:min, :birth_time), Sequel.function(:max, :birth_time)).first)
    end
  end
end
