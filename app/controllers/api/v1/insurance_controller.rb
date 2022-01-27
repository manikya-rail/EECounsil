module Api
  module V1
    class InsuranceController < ApplicationController
      before_action :get_access_token, except: :payers_list
      before_action :fetch_patient, only: [:patient_eligibility, :claim_status, :validate_and_submit_claim]
      before_action :fetch_therapist, only: [:patient_eligibility, :claim_status, :validate_and_submit_claim]
      before_action :fetch_schedule, only: [:patient_eligibility, :claim_status, :validate_and_submit_claim]

      def payers_list
        render json: {payers: ActiveModel::ArraySerializer.new(Payer.all, each_serializer: PayerSerializer)}
      end

      def patient_eligibility
        schedule = Schedule.find(params[:schedule_id])
        access_token = Insurance.get_access_token
        patient_eligibility = Insurance.check_patient_eligibility(@patient, @therapist, schedule, access_token)
        if patient_eligibility.is_a?(ActiveRecord::Base)
          render json: {eligible: patient_eligibility.eligible ? 'True' : 'False', pre_amount: patient_eligibility.pre_amount,
                        copay_amount: patient_eligibility.co_pay, deductible_amount: patient_eligibility.deductible,
                        co_insurance_amount:patient_eligibility.co_insurance, out_of_pocket_amount: patient_eligibility.out_of_pocket,
                        patient_eligibility_id: patient_eligibility.id}
        else
          errors_hsh = {error_description: patient_eligibility.map{|ele| ele['description']}}
          render json: {response_body: errors_hsh}
        end
      end

      def schedules_list
        get_schedules
        render json: {schedules: @remaining_schedules}
      end

      def claim_form_info
        get_schedules
        schedules = ActiveModel::ArraySerializer.new(@remaining_schedules, each_serializer: SchedulesSerializer)
        claim_filing_codes = [['09', 'Self-pay'], ['11', 'Other Non-Federal Programs'], ['12', 'Preferred Provider Organization (PPO)'],
                              ['14', 'Exclusive Provider Organization (EPO)'], ['15', 'Indemnity Insurance'], ['16', 'Health Maintenance Organization (HMO) Medicare Risk'],
                              ['BL', 'Blue Cross/Blue Shield'], ['CH', 'CHAMPUS'], ['CI', 'Commercial Insurance Co.'],
                              ['HM', 'Health Maintenance Organization'], ['MA', 'Medicare Part A'], ['MB', 'Medicare Part B'],
                              ['MC', 'Medicaid'], ['OF', 'Other Federal Program'], ['VA', 'Veterans Affairs Plan'],
                              ['WC', "Workers' Compensation Health Claim"]]
        claim_frequency_codes = [['1', 'Original Claim'], ['7', 'Corrected Claim'], ['8', 'Void/Canceled Claim']]
        signature_indicator = [['Y', 'Yes'], ['N', 'No']]
        coverage_type = [
            ['MEDICARE', 'Medicare'],
            ['MEDICAID', 'Medicaid'],
            ['Tricare', 'ID/DoD'],
            ['CHAMPVA', 'MemberID'],
            ['GROUP HEALTH PLAN', 'ID'],
            ['FECA BLK LUNG', 'ID'],
            ['OTHER', 'ID'],
        ]
        plan_participation_codes = [['A', 'Assigned  Not Provided'], ['B', 'Assignment Accepted on Clinical Lab Services Only Not Provided'], ['C', 'Not Assigned']]
        benefits_assignment_certification_indicator = [['N', 'No'], ['W', 'Not Applicable'], ['Y', 'Yes']]
        release_information_codes = [['Y', 'Yes'], ['N', 'No']]
        diagnosis_type_codes = [['ABF', 'International Classification of Diseases Clinical Modification (ICD-10-CM) Diagnosis'],
                                ['ABJ', 'International Classification of Diseases Clinical Modification (ICD-10-CM) Admitting Diagnosis'],
                                ['ABK', 'International Classification of Diseases Clinical Modification (ICD-10-CM) Principal Diagnosis'],
                                ['APR', "International Classification of Diseases Clinical Modification (ICD-10-CM) Patient's Reason for Visit"],
                                ['BF', 'International Classification of Diseases Clinical Modification (ICD-9-CM) Diagnosis'],
                                ['BJ', 'International Classification of Diseases Clinical Modification (ICD-9-CM) Admitting Diagnosis'],
                                ['BK', 'International Classification of Diseases Clinical Modification (ICD-9-CM) Principal Diagnosis'],
                                ['DR', 'Diagnosis Related Group (DRG)'],
                                ['LOI', 'Logical Observation Identifier Names and Codes (LOINC<190>) Codes'],
                                ['PR', "International Classification of Diseases Clinical Modification (ICD-9-CM) Patient's Reason for Visit"]]
        place_of_service_codes = ActiveModel::ArraySerializer.new(PlaceOfServiceCode.all, each_serializer: PlaceOfServiceCodeSerializer)
        diagnosis_codes = ActiveModel::ArraySerializer.new(DiagnosisCode.all, each_serializer: DiagnosisCodeSerializer)
        render json: {schedules: schedules, claim_filing_codes: claim_filing_codes, claim_frequency_codes: claim_frequency_codes, signature_indicator: signature_indicator,plan_participation_codes: plan_participation_codes,
                      benefits_assignment_certification_indicator: benefits_assignment_certification_indicator, release_information_codes: release_information_codes,
                      place_of_service_codes: place_of_service_codes, diagnosis_type_codes: diagnosis_type_codes,
                      diagnosis_codes: diagnosis_codes, coverage_type:coverage_type}
      end

      def create_patient_claim
        schedule = Schedule.find_by(id: params[:schedule_id])
        patient = Patient.find_by(id: params[:patient_id])
        therapist = Therapist.find_by(id: params[:therapist_id])
        payer = Payer.find_by(id: params[:trading_partner_service_id])
        patient_eligibility = PatientEligibility.find_by(patient_id: params[:patient_id], therapist_id: params[:therapist_id], schedule_id: params[:schedule_id])
        patient_claim = PatientClaim.find_or_create_by(patient_id: params[:patient_id], therapist_id: params[:therapist_id], schedule_id: params[:schedule_id])
        patient_claim.update(payment_responsibility_level_code: 'P',
                             provider_type: params[:provider_type],
                             control_number: '000000001',
                             measurement_unit: params[:measurement_unit],
                             patient_control_number: '00001',
                             service_unit_count: params[:service_unit_count],
                             trading_partner_service_id: payer.id,
                             place_of_service_code: params[:place_of_service_code],
                             claim_frequency_code: params[:claim_frequency_code],
                             signature_indicator: params[:signature_indicator],
                             plan_participation_code: params[:plan_participation_code],
                             accept_assignment: params[:benefits_assgmt_certification_indicator],
                             coverage_type: params[:coverage_type],
                             patient_member_id: patient.user_insurance_detail.member_id,
                             patient_name: patient.full_name,
                             patient_dob: patient.birth_date,
                             patient_gender: patient.gender,
                             patient_street_address: patient.address.street_address,
                             therapist_city: therapist.address.city,
                             therapist_zip: therapist.address.zip,
                             therapist_state: therapist.address.state,
                             therapist_phone: therapist.phone_number,
                             patient_relation_to_insured: params[:patient_relation_to_insured],
                             insured_name: params[:insured_name],
                             insured_street_address: params[:insured_street_address],
                             insured_city: params[:insured_city],
                             insured_state: params[:insured_state],
                             insured_zip: params[:insured_zip],
                             insured_phone: params[:insured_phone],
                             insured_policy_number: patient.user_insurance_detail.policy_number,
                             insured_dob: patient.birth_date,
                             insured_gender: params[:insured_gender],
                             insured_plan_name: payer.payer_name,
                             claim_codes: params[:claim_filing_code],
                             therapist_name: therapist.full_name,
                             patient_city: patient.address.city,
                             patient_zip: patient.address.zip,
                             patient_state: patient.address.state,
                             patient_phone: patient.phone_number,
                             therapist_npi: therapist.user_insurance_detail.npi,
                             date_of_service_from: schedule.starts_at,
                             date_of_service_to: schedule.ends_at,
                             charges: TherapistRatePerClient.find_by(therapist_id: therapist.id, patient_id: patient.id).default_rate,
                             days_or_units: params[:days_or_units],
                             therapist_ssn: therapist.user_insurance_detail.ssn,
                             release_information_code: params[:release_information_code],
                             diagnosis_identifier: params[:diagnosis_type_code],
                             diagnosis_code: params[:diagnosis_code],
                             procedure_identifier: params[:procedure_identifier],
                             procedure_code: ProcedureCode.find(schedule.procedure_code_id).code,
                             diagnosis_code_pointers: params[:diagnosis_code_pointers],
                             patient_account_no: (10.times.map{rand(Integer([patient.id,therapist.id,schedule.id].join, 10))}.join)[0..9],
                             amount_paid: patient_eligibility&.pre_amount,
                             status: "Creating")
        if patient_claim
          render json: {msg: "Success", patient_claim: patient_claim}
        else
          render json: {errors: patient_claim.errors}
        end


      end


      def update_pre_amount
        @patient_eligibility = PatientEligibility.find(params[:patient_eligibility_id])
        if @patient_eligibility.update!(pre_amount: params[:pre_amount])
          @patient_eligibility_hsh = @patient_eligibility.as_json
          @patient_eligibility_hsh['eligible'] = @patient_eligibility.eligible ? 'True' : 'False'
          render json: {msg: "Successfully Updated", patient_eligibility: @patient_eligibility_hsh}
        else
          render json: @patient_eligibility.errors
        end
      end

      def validate_and_submit_claim
        response_body = invoke_claim_apis(params[:method])
        if response_body['errors'].present?
          errors_hsh = {error_description: response_body['errors'].map{|ele| ele['description']}}
          render json: {response_body: errors_hsh}
        else
          render json: {response_body: response_body}
        end
      end

      def claim_status
        response_body = invoke_claim_apis('status')
         if response_body['errors'].present?
          errors_hsh = {error_description: response_body['errors'].map{|ele| ele['description']}}
          render json: {response_body: errors_hsh}
        else
          render json: {response_body: response_body}
        end
      end

      private

      def get_access_token
        params = [['client_id', APP_CONFIG['CHANGE_HEALTH_ACCESS_KEY']], ['client_secret', APP_CONFIG['CHANGE_HEALTH_SECRET_KEY']], ['grant_type', 'client_credentials']]
        uri = URI.parse("https://sandbox.apis.changehealthcare.com/apip/auth/v2/token")
        response = Net::HTTP.post_form(uri, params)
        Rails.logger.info "----------------OP:------------------#{response.body} ---------------------------------------"
        @access_token = JSON.parse(response.body)['access_token']
      end

      def fetch_patient
        @patient = Patient.find(params[:patient_id])
      end

      def fetch_therapist
        @therapist = Therapist.find(params[:therapist_id])
      end

      def fetch_schedule
        @schedule = Schedule.find(params[:schedule_id])
      end

      def invoke_claim_apis(api_name)
        @patient_claim = PatientClaim.find_by(patient_id: @patient.id, therapist_id: @therapist.id, schedule_id: @schedule.id)
        headers = {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + @access_token
        }
        url = api_name == 'status' ? "https://sandbox.apis.changehealthcare.com/medicalnetwork/claimstatus/v2" : "https://sandbox.apis.changehealthcare.com/medicalnetwork/professionalclaims/v3/#{api_name}"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, headers)
        api_name == 'status' ? claim_status_request_body : claim_submit_request_body
        req.body = @claim_request_hsh.to_json
        responses = http.request(req)
        print "-------------cde #{responses.code}"
        Rails.logger.info "----------------OP:------------------#{responses.body} ---------------------------------------"
        response_body = JSON.parse(responses.body)
        if api_name == 'submission' && response_body['status'] == 'SUCCESS'
          @patient_claim.update(claim_number: response_body['claimReference']['customerClaimNumber'])
        end
        response_body
      end

      def claim_status_request_body
        @claim_request_hsh = {
            "controlNumber": @patient_claim.control_number,
            "tradingPartnerServiceId": @patient_claim.trading_partner_service_id,
            "providers": [{
                              "organizationName": @therapist.last_name,
                              "taxId": @therapist.user_insurance_detail.tax_id,
                              "providerType": "BillingProvider"
                          }],
            "subscriber": {
                "memberId": @patient.user_insurance_detail.member_id,
                "firstName": @patient.first_name,
                "lastName": @patient.last_name,
                "gender": @patient.gender.capitalize[0],
                "dateOfBirth": DateTime.strptime(@patient.birth_date, "%m/%d/%Y").to_s.split(":").first.split("T").first.gsub('-', ''),
                "policyNumber": @patient.user_insurance_detail.policy_number
            },
            "encounter": {
                "trackingNumber": "ABCD"
            }
        }
      end

      def claim_submit_request_body
        @subscriber_hsh, @providers_hsh, @claim_information_hsh, @service_lines_hsh = {}, {}, {}, {}
        @charge = TherapistRatePerClient.find_by(therapist_id: @therapist.id, patient_id: @patient.id).default_rate
        submitter_hsh = {"organizationName": 'happy doctors group',
                         "contactInformation": {
                             "name": @therapist.full_name,
                             "phoneNumber": @therapist.phone_number
                         }}
        receiver_hsh = {"organizationName": 'happy doctors group'}
        get_provider_hsh
        get_subscriber_hsh
        get_claim_information_hsh
        @claim_request_hsh = {"controlNumber": @patient_claim.control_number, "tradingPartnerServiceId": "9496"}
        @claim_request_hsh.merge!('submitter': submitter_hsh, 'receiver': receiver_hsh, 'subscriber': @subscriber_hsh, 'providers': [@providers_hsh], 'claimInformation': @claim_information_hsh)
      end

      def get_state_code(state)
        states = CS.states(:us)
        states.key(state).downcase
      end

      def get_subscriber_hsh
        @subscriber_hsh.merge!("memberId": @patient.user_insurance_detail.member_id,
                               "paymentResponsibilityLevelCode": @patient_claim.payment_responsibility_level_code,
                               "firstName": @patient.first_name,
                               "lastName": @patient.last_name,
                               "gender": @patient.gender.capitalize[0],
                               "dateOfBirth": DateTime.strptime(@patient.birth_date, "%m/%d/%Y").to_s.split(":").first.split("T").first.gsub('-', ''),
                               "policyNumber": @patient.user_insurance_detail.policy_number,
                               "address": {
                                   "address1": @patient.address.street_address,
                                   "city": @patient.address.city,
                                   "state": get_state_code(@patient.address.state),
                                   "postalCode": @patient.address.zip})
      end

      def get_provider_hsh
        @providers_hsh.merge!("providerType": @patient_claim.provider_type,
                              "npi": @therapist.user_insurance_detail.npi,
                              "employerId": @therapist.user_insurance_detail.tax_id,
                              "organizationName": 'happy doctors group',
                              "address": {
                                  "address1": @therapist.address.street_address,
                                  "city": @therapist.address.city,
                                  "state": get_state_code(@therapist.address.state),
                                  "postalCode": @therapist.address.zip
                              },
                              "contactInformation": {
                                  "name": @therapist.full_name,
                                  "phoneNumber": @therapist.phone_number
                              })

      end

      def get_claim_information_hsh
        get_service_lines_hsh
        @claim_information_hsh.merge!("claimFilingCode": @patient_claim.claim_codes,
                                      "patientControlNumber": @patient_claim.patient_control_number,
                                      "claimChargeAmount": @patient_claim.charges,
                                      "placeOfServiceCode": @patient_claim.place_of_service_code,
                                      "claimFrequencyCode": @patient_claim.claim_frequency_code,
                                      "signatureIndicator": @patient_claim.signature_indicator,
                                      "planParticipationCode": @patient_claim.plan_participation_code,
                                      "benefitsAssignmentCertificationIndicator": @patient_claim.accept_assignment,
                                      "releaseInformationCode": @patient_claim.release_information_code)
        # @claim_information_hsh.merge!("healthCareCodeInformation": [{"diagnosisTypeCode": @patient_claim.diagnosis_type_code, "diagnosisCode": @patient_claim.diagnosis_code}])
        @claim_information_hsh.merge!("healthCareCodeInformation": [{
                                                                        "diagnosisTypeCode": "BK",
                                                                        "diagnosisCode": "496"
                                                                    },{
                                                                        "diagnosisTypeCode": "BF",
                                                                        "diagnosisCode": "25000"
                                                                    }])
        @claim_information_hsh.merge!("serviceLines": [@service_lines_hsh])

      end

      def get_service_lines_hsh
        professional_service_hsh = {}
        professional_service_hsh.merge!("procedureIdentifier": 'HC',
                                        "lineItemChargeAmount": @patient_claim.charges,
                                        "procedureCode": @patient_claim.procedure_code,
                                        "measurementUnit": @patient_claim.measurement_unit,
                                        "serviceUnitCount": '1',
                                        "compositeDiagnosisCodePointers": {
                                            "diagnosisCodePointers": [@patient_claim.diagnosis_code_pointers]
                                        })
        service_date = (@patient_claim.date_of_service_from.strftime("%Y-%m-%d")).to_s.split(":").first.split("T").first.gsub('-', '')
        @service_lines_hsh.merge!("serviceDate": service_date, "professionalService": professional_service_hsh)
      end

      def get_schedules
        patient_claims = PatientClaim.where(patient_id: params[:patient_id], therapist_id: params[:therapist_id])
        @remaining_schedules = Schedule.where.not(id: patient_claims.pluck(:schedule_id)).where("patient_id = ? AND therapist_id = ? AND schedule_date <= ? AND status = ?", params[:patient_id],params[:therapist_id], Date.today, "booked").order('schedule_date')
      end
    end
  end
end

