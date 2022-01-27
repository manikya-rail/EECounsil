class DeleteObseluteMeeting
  require 'net/http'
  require 'net/https'
  require 'uri'

  def self.perform(therapist_id, patient_id)
    print "*******Started \n"
    @access_token = ZoomIntegration.where(config_name: 'ZOOM_OAUTH_ACCESS_TOKEN').first.value
    @refresh_token = ZoomIntegration.where(config_name: 'ZOOM_OAUTH_REFRESH_TOKEN').first.value
    list_previous_meetings(therapist_id, patient_id)
    if JSON.parse(@response.body)['code'] == 124
      @access_token = get_refresh_token
      list_previous_meetings(therapist_id, patient_id)
    end
  end

  def self.get_refresh_token
    auth_token = Base64.strict_encode64("#{APP_CONFIG['ZOOM_OAUTH_CLIENT_ID']}:#{APP_CONFIG['ZOOM_OAUTH_CLIENT_SECRET']}")
    uri = URI.parse("https://zoom.us/oauth/token?grant_type=refresh_token&refresh_token=#{@refresh_token}")
    headers = {'Authorization': 'Basic ' + auth_token }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri, headers)
    res = http.request(req)
    access_token = JSON.parse(res.body)['access_token']
    refresh_token = JSON.parse(res.body)['refresh_token']
    ZoomIntegration.where(config_name: 'ZOOM_OAUTH_ACCESS_TOKEN').first.update!(value: access_token) if access_token.present?
    ZoomIntegration.where(config_name: 'ZOOM_OAUTH_REFRESH_TOKEN').first.update!(value: refresh_token) if refresh_token.present?
    print "----------------Refresh token OP:------------------#{res.body} ---------------------------------------\n"
    access_token
  end

  def self.list_previous_meetings(therapist_id, patient_id)
    @meeting_id = VideoCall.where(sender_id: therapist_id, receiver_id: patient_id).where.not(meeting_id: nil).last.meeting_id
    headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + @access_token
    }
    uri = URI.parse("https://api.zoom.us/v2/meetings/#{@meeting_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.path, headers)
    @response = http.request(req)
    prev_meeting_status = JSON.parse(@response.body)["status"]
    print "----------------\nPREVIOUS MEETING OP:------------------#{@response.body} ---------------------------------------\n"
    delete_previous_meeting(headers) if prev_meeting_status == 'waiting' || prev_meeting_status == 'started'
    update_prev_meeting_status(headers) if @delete_response&.body.present? && JSON.parse(@delete_response.body)['code'] == 3002
  end

  def self.delete_previous_meeting(headers)
    uri = URI.parse("https://api.zoom.us/v2/meetings/#{@meeting_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Delete.new(uri.path, headers)
    @delete_response = http.request(req)
    print "----------------------DELETE RESP BODY ----------#{@delete_response.body}--------------"
    print "----------------\nDELETE OP:------------------#{@delete_response.code} ---------------------------------------\n"
  end

  def self.update_prev_meeting_status(headers)
    meetingRequestBody = { "action": "end" }
    uri = URI.parse("https://api.zoom.us/v2/meetings/#{@meeting_id}/status")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Put.new(uri.path, headers)
    req.body = meetingRequestBody.to_json
    response = http.request(req)
    print "-------------------UPDATE RESP: ----------#{response.code} ----------------------------"
    print "-------------------UPDATE RESP BODY: ----------#{response.body} ----------------------------"
  end

end
