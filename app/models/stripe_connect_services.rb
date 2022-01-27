class StripeConnectServices
  DEFAULT_CURRENCY = 'usd'.freeze

  def initialize(params, user)
    @account_number = params[:account_number]
    @routing_number = params[:routing_number]
    @ssn_last_4 = params[:ssn_last_4]
    @ip_address = params[:ip_address]
    @birth_date = params[:birth_date].to_date.strftime('%m/%d/%Y')
    @user = user
  end

  attr_accessor :user, :account_number, :routing_number, :ssn_last_4, :ip_address

  def call
    begin
    dob = @birth_date.split('/')
    connect_details  = Stripe::Account.create({
                          type: 'custom',
                          country: user.address.country,
                          email: user.email,
                          requested_capabilities: ['card_payments', 'transfers'],
                          external_account: { object: 'bank_account', country: user.address.country, currency: 'usd', account_number: account_number, routing_number: routing_number },
                          business_type: 'individual',
                          business_profile: { name: user.full_name, url: 'ecounsel.com', mcc: "5734"},
                          settings: {
                            payments: { statement_descriptor: user.full_name}
                          },
                          individual: {
                          dob: {
                          day: dob[1],
                          month: dob[0],
                          year: dob[2],
                          },
                          address: {
                            city: user.address.city.to_s,
                            line1: user.address.street_address,
                            postal_code: user.address.zip.to_s,
                            state: user.address.state.to_s,
                          },
                          first_name: user.first_name,
                          last_name: user.last_name,
                          ssn_last_4: ssn_last_4,
                          email: user.email,
                          phone: user.phone_number,
                          },
                          tos_acceptance: {
                          date: Time.now.to_i,
                          ip: ip_address,
                          }
                        })
    @details = save_details(connect_details,user);
    rescue Stripe::StripeError => e
      { error: e.message }
    end

  end

  private

  def save_details(connect_details,user)
    details = connect_details
    user.update(stripe_connect_account_id: details.id , stripe_bank_account_id: details.external_accounts.data[0].id)
    details
  end

end
