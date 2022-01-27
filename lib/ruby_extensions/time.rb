require 'active_support/core_ext/numeric' # from gem 'activesupport'
class Time
  # Time#round already exists with different meaning in Ruby 1.9
  def round_off(minutes = 15)
  	seconds = minutes * 60
    Time.zone.at((self.to_f / seconds).round * seconds).rfc2822
  end

  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds)
  end

	def slots_between(end_time, step=30)
    ((self.round_off(30.minutes)) .. (end_time.round_off(30.minutes))).step(step.minutes).each do |time|
      puts "Create Slot Date: {date.strftime('%D')} Time: #{Time.at( time )}"
    end
  end
end

