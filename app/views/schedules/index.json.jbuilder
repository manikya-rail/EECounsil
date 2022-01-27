json.array!(@schedules) do |schedule|
  json.extract! schedule, :id, :status, :schedule_date, :starts_at, :ends_at
  json.start schedule.starts_at
  json.end schedule.ends_at
  json.therapist schedule.therapist.first_name+' '+schedule.therapist.last_name
  json.patient schedule.patient.first_name+' '+schedule.patient.last_name
  # json.stats_at schedule.starts_at.strftime("%I:%M %p")
  # json.end_at schedule.ends_at.strftime("%I:%M %p")
  # json.url schedule_url(schedule, format: :html)
end