class AddTherapistIdAndPatientIdToElectronicNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :electronic_notes, :therapist_id, :integer, references: true
    add_column :electronic_notes, :patient_id, :integer, references: true
  end
end
