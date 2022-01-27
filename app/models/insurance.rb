class Insurance < ApplicationRecord

  def self.check_patient_eligibility(patient, therapist, schedule, access_token)
    headers = {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer ' + access_token
    }
    uri = URI.parse("https://sandbox.apis.changehealthcare.com/medicalnetwork/eligibility/v3")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, headers)
    @eligibilityRequestBody =
        {
            "controlNumber": "123456789",
            "tradingPartnerServiceId": patient&.user_payers&.first&.payer.payer_id,
            "provider":
                {
                    "organizationName": therapist.last_name,
                    "npi": therapist.user_insurance_detail.npi,
                    "contactNumber": therapist.phone_number
                },
            "subscriber": {
                "memberId": patient.user_insurance_detail.member_id,
                "firstName": patient.first_name,
                "lastName": patient.last_name,
                "dateOfBirth": DateTime.strptime(patient.birth_date, "%m/%d/%Y").to_s.split(":").first.split("T").first.gsub('-', ''),
                "groupNumber": patient.user_insurance_detail.group_number
            }
        }
    req.body = @eligibilityRequestBody.to_json
    responses = http.request(req)
    if responses.code == '200'
      eligibility_hash = JSON.parse(responses.body)
      Rails.logger.info "----------------Eligibility hash:------------------#{eligibility_hash} ---------------------------------------"
      create_patient_eligibility(eligibility_hash, patient.id, therapist.id, schedule.id)
    else
      return JSON.parse(responses.body)['errors']
    end

  end

  def self.create_patient_eligibility(eligibility_hash, patient_id, therapist_id, schedule_id)
    unless eligibility_hash['errors'].present?
      co_pay_benefit_amount = eligibility_hash["benefitsInformation"].select { |ele| ele['code'] == 'B' }.map { |ele| ele['benefitAmount'].to_f }.sum
      co_insurance_benefit_amount = eligibility_hash["benefitsInformation"].select { |ele| ele['code'] == 'A' }.map { |ele| ele['benefitAmount'].to_f }.sum
      deductible_benefit_amount = eligibility_hash["benefitsInformation"].select { |ele| ele['code'] == 'C' }.map { |ele| ele['benefitAmount'].to_f }.sum
      out_of_pocket_benefit_amount = eligibility_hash["benefitsInformation"].select { |ele| ele['code'] == 'G' }.map { |ele| ele['benefitAmount'].to_f }.sum
      eligibility_status = eligibility_hash["planStatus"].first["status"] == 'Active Coverage' ? true : false
      patient_eligibility = PatientEligibility.find_or_create_by(patient_id: patient_id, therapist_id: therapist_id, schedule_id: schedule_id)
      patient_eligibility.update(control_number: eligibility_hash["controlNumber"],
                                 trading_service_payer_id: eligibility_hash["tradingPartnerServiceId"], eligible: eligibility_status, deductible: deductible_benefit_amount, co_pay: co_pay_benefit_amount.to_s,
                                 co_insurance: co_insurance_benefit_amount.to_s, out_of_pocket: out_of_pocket_benefit_amount.to_s, claim_amount: "0")
      return patient_eligibility
    else
      return eligibility_hash['errors']
    end

  end

  def self.get_access_token
    params = [['client_id', APP_CONFIG['CHANGE_HEALTH_ACCESS_KEY']], ['client_secret', APP_CONFIG['CHANGE_HEALTH_SECRET_KEY']], ['grant_type', 'client_credentials']]
    uri = URI.parse("https://sandbox.apis.changehealthcare.com/apip/auth/v2/token")
    response = Net::HTTP.post_form(uri, params)
    Rails.logger.info "----------------OP:------------------#{response.body} ---------------------------------------"
    JSON.parse(response.body)['access_token']
  end
end
