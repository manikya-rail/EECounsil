class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your Custom Therapist-Client Platform')
  end

  def notify_therapist_about_client_register(patient, user)
    @user = user
    @patient = patient
    mail(from: 'registration@ecounsel.com <registration@ecounsel.com>', to: @user.email, subject: "#{patient} Has Registered With You")
  end

  def login_email(user)
    @user = user
    mail(to: @user.email, subject: 'You have registerd to Therapist-Client-Application')
  end

  def autoresponce_mail(user)
    @user = user
    mail(to: @user.email, subject: 'Please select the package, there is 50% off today')
  end

  def notify_admin(user)
    @user = user
    @admin = User.with_role :admin
    mail(to: @admin.first.email, subject: 'Deactivate Therapist')
  end

  def notify_admin_about_premium_plan_user(user)
    @user = user
    mail(to: 'info@ecounsel.com <info@ecounsel.com>', subject: 'Premium Plan user notification')
  end

  def account_activity_status(user,status)
    @user , @status = user ,status
    mail(to: @user.email, subject: 'Account '+status)
  end

  def appointment_alert(user, other, schedule)
    @user = user
    @other = other
    @schedule = schedule
    mail(to: @user.email, subject: 'Appointment Alert')
  end

  def appointment_reminder(user, other, schedule)
    @user = user
    @other = other
    @schedule = schedule
    mail(to: @user.email, subject: 'Appointment Reminder for Today')
  end

  def success_payout(user,amount)
    @user = user
    @amount = amount
    mail(to: @user.email, subject: 'Payment Transfer')
  end

  def notify_user_about_schedule(schedule, user, state, other_user, email, mail_user)
    @schedule = schedule
    @user = user
    @mail_user = mail_user
    @state = state
    @other_user = other_user
    mail(from: 'appointment@ecounsel.com <appointment@ecounsel.com>', to: other_user.email, subject: 'Appointment '+@schedule.status) if @schedule.schedule_date
  end

  def request_demo(params, emails)
    @email = params[:email]
    @fullname = params[:fullName]
    @email = params[:companyName]
    mail(to: emails, subject: 'Demo Request')
  end

  def patients_invite(user, email, rate, form_ids)
    @user = user
    @default_rate = rate
    @form_ids = form_ids
    mail(from: "therapist@ecounsel.com <therapist@ecounsel.com>", to: email, subject: "#{@user.full_name} has sent you an important invitation")
  end

  def notify_therapist_about_promo(user, promo_code)
    @user = user
    @promo_code = promo_code
    mail(to: user.email, subject: 'Special Offer')
  end

  def send_message_notification(sender, receiver)
    @sender = sender
    @receiver = receiver
    mail(to: receiver.email, subject: 'Message notification')
  end

end
