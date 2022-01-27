module Api
  module V1
    class TherapistsController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken
      before_action :authenticate_user!, except: [:show, :zoom_end_meeting]
      before_action :find_therapist
      require 'net/http'
      require 'net/https'
      require 'uri'
      require 'logger'

      def show
        consent_forms = ConsentForm.find(params[:form_ids].split(','))
        ids = UserPayer.where(user_id: @therapist.id)&.pluck(:payer_id)
        therapist_payers = Payer.select(:id, :payer_id, :payer_name).where(id: ids)
        therapist_payers_ary = therapist_payers.present? ? ActiveModel::ArraySerializer.new(therapist_payers, each_serializer: PayerSerializer) : []
        render json: {id: @therapist.id, name: @therapist.full_name, practice_name: @therapist.practice_name,
                       consent_forms: consent_forms, therapist_payers: therapist_payers_ary}
      end

      def invite_patients
        @therapist.send_invite_patient_mail(params[:emailIds], params[:form_ids])
        render json: {msg: 'Success'}
      end

      def update_patient_default_rate
        @therapist.update_patient_default_rate(params[:patient_id], params[:default_rate])
        render json: {msg: 'Success'}
      end

      def create_meeting
        @access_token = ZoomIntegration.where(config_name: 'ZOOM_OAUTH_ACCESS_TOKEN').first.value
        res_code = check_if_zoom_user
        if res_code.to_s == '200'
          @meetingRequestBody = {
                "topic": "Ecounsel Video Conference",
                "settings": {
                    "host_video": "true",
                    "participant_video": "true"
                }
          }
          @meeting_id = VideoCall.where(sender_id: params[:id], receiver_id: params[:patientId]).where.not(meeting_id: nil).last.try(:meeting_id)
          initiate_zoom_api_call
          if JSON.parse(@response.body)['code'] == 124
            @access_token = ZoomIntegration.get_refresh_token
            initiate_zoom_api_call
          end
          previous_meeting if @meeting_id
          render json: {zoom: JSON.parse(@response.body), zoom_user_approved: true}
          if @response.code == '201'
            res = JSON.parse(@response.body)
            meeting_id = res['id']
            host_id = res['host_id']
            ActionCable.server.broadcast "notifications:#{params[:patientId]}", {}.merge(action: 'createmeetingaction', media: [], caller: @therapist, sender_id: params[:id], receiver_id: params[:patientId], prev_meeting_id: @meeting_id, curr_meeting_id: meeting_id, host_id: host_id )
          end
        else
          render json: {zoom_user_approved: false}
        end
      end

      def zoom_end_meeting
        therapist = Therapist.find_by(email: params[:userEmail])
        ActionCable.server.broadcast "notifications:#{therapist.id}", {}.merge(action: 'zoomendmeetingaction', media: [], caller: therapist, sender_id: therapist.id, receiver_id: params[:patientId], curr_meeting_id: params[:meetingId], host_id: params[:hostId] )
        ActionCable.server.broadcast "notifications:#{params[:patientId]}", {}.merge(action: 'zoomendmeetingaction', media: [], caller: therapist, sender_id: therapist.id, receiver_id: params[:patientId], curr_meeting_id: params[:meetingId], host_id: params[:hostId] )
        render json: {success: 'True'}
      end

      def zoom_meeting_status
        @access_token = ZoomIntegration.where(config_name: 'ZOOM_OAUTH_ACCESS_TOKEN').first.value
        get_meeting_status
        if JSON.parse(@meeting_response.body)['code'] == 124
          @access_token = ZoomIntegration.get_refresh_token
          get_meeting_status
        end
        render json: {meeting_status: JSON.parse(@meeting_response.body)['status']}
      end

      private

      def find_therapist
        @therapist = Therapist.find(params[:id])
      end

      def initiate_zoom_api_call
        headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + @access_token
        }
        uri = URI.parse("https://api.zoom.us/v2/users/#{@therapist.email}/meetings")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, headers)
        req.body = @meetingRequestBody.to_json
        @response = http.request(req)
        print "-------------cde #{@response.code}"
        Rails.logger.info "----------------OP:------------------#{@response.body} ---------------------------------------"
      end

      def previous_meeting
        if @meeting_id
          headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + @access_token
          }
          uri = URI.parse("https://api.zoom.us/v2/meetings/#{@meeting_id}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          req = Net::HTTP::Get.new(uri.path, headers)
          response = http.request(req)
          prev_meeting_status = JSON.parse(response.body)["status"]
          Rails.logger.info "----------------PREVIOUS MEETING OP:------------------#{response.body} ---------------------------------------"
          update_prev_meeting_status(headers) if prev_meeting_status == 'waiting' || prev_meeting_status == 'started'
        end
      end

      def update_prev_meeting_status(headers)
        meetingRequestBody = { "action": "end" }
        uri = URI.parse("https://api.zoom.us/v2/meetings/#{@meeting_id}/status")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Put.new(uri.path, headers)
        req.body = meetingRequestBody.to_json
        response = http.request(req)
        Rails.logger.info "-------------------UPDATE RESP: ----------#{response.code} ----------------------------"
        Rails.logger.info "-------------------UPDATE RESP BODY: ----------#{response.body} ----------------------------"
      end

      def check_if_zoom_user
        res_code = get_zoom_user
        if JSON.parse(@zoom_usr_response.body)['code'] == 124
          @access_token = ZoomIntegration.get_refresh_token
          res_code = get_zoom_user
        end
        return res_code
      end

      def get_zoom_user
        headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + @access_token
          }
        uri = URI.parse("https://api.zoom.us/v2/users/#{@therapist.email}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(uri.path, headers)
        @zoom_usr_response = http.request(req)
        Rails.logger.info "------------------GET USER RESP: ----------#{@zoom_usr_response.code} ----------------------------"
        Rails.logger.info "------------------GET USER RESP BODY: ----------#{@zoom_usr_response.body} ----------------------------"
        return @zoom_usr_response.code
      end

      def get_meeting_status
        headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + @access_token
          }
        uri = URI.parse("https://api.zoom.us/v2/meetings/#{params[:meetingId]}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(uri.path, headers)
        @meeting_response = http.request(req)
        Rails.logger.info "------------------GET Meeting RESP: ----------#{@meeting_response.body} ----------------------------"
      end
    end
  end
end
