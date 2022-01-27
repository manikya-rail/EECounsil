#rake delete_obselute_meetings:delete_zoom_meetings[136,138]
namespace :delete_obselute_meetings do
  desc "Delete obselute zoom meetings"
  task :delete_zoom_meetings, [:therapist_id, :patient_id] => :environment do |t, args|
    DeleteObseluteMeeting.perform(args[:therapist_id], args[:patient_id])
  end
end
