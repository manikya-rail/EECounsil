class HardWorker
  include Sidekiq::Worker

  def perform(*args)
    # Schedule.send_sms_and_email_appointment_alert
    Schedule.schedule_charges_from_patients
    p 'Hello World!'
  end
end
