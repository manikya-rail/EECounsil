module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end
    private
      def find_verified_user
        puts '-----------Cable params------------'
        puts request.params
        access_token = request.params[:'token']
        client_id = request.params[:client]
        uid = request.params[:uid]
        verified_user = User.find_by(email: uid)
        if verified_user && verified_user.valid_token?(access_token, client_id)
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
