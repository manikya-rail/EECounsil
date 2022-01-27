date_format = schedule.all_day_schedule? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'
json.id schedule.id
json.title schedule.title
json.start schedule.start.strftime(date_format)
json.end schedule.end.strftime(date_format)

json.color schedule.color unless schedule.color.blank?
json.allDay schedule.all_day_schedule? ? true : false

