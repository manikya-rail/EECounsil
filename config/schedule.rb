set :environment, "development"
set :output, "cron_log.log"
every 1.day, at: '12pm' do
  runner "User.send_auto_response_mail"
end

every 1.minute do
  runner "Schedule.send_appointment_alert"
  runner "Schedule.schedule_charges_from_patients"
end

every 1.day, at: '12pm' do
  runner "Schedule.check_expire_schedules"
end

every 1.day, at: '6am' do
  runner "User.send_promocode_mail"
end
# Learn more: http://github.com/javan/whenever
