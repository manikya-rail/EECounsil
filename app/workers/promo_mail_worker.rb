class PromoMailWorker
  include Sidekiq::Worker

  def perform(*args)
    p 'PromoWorker started'
    User.send_promocode_mail
    p 'Promo emails sent'
  end
end
