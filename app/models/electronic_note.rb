class ElectronicNote < ApplicationRecord

	class << self
		def note_of_schedule schedule
			note = where(therapist_id:  schedule.therapist_id, patient_id: schedule.patient_id).first
			if note.nil?
				note = new(therapist_id:  schedule.therapist_id, patient_id: schedule.patient_id)
				note.save
			end
			return note
		end

		def note_between_patient_therapist patient_id, therapist_id
			note = where(therapist_id:  therapist_id, patient_id: patient_id).first
			if note.nil?
				note = new(therapist_id:  therapist_id, patient_id: patient_id)
				note.save
			end
			return note
		end
	end
end
