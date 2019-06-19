class ApplicationController < ActionController::API
  private
  def expiration_at(t, hour, minute = 0)
    if t.hour < hour
      Time.gm(t.year, t.month, t.day, hour, minute, 0)
    else
      t2 = t + 24*60*60
      Time.gm(t2.year, t2.month, t2.day, hour, minute, 0)
    end
  end

  def expiration_in(hour, minute = 0)
    t = Time.now
    [expiration_at(t, hour, minute) - t, 60*60].max
  end
end
