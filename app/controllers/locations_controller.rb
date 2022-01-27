class LocationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @addresses = Address.all.where.not(latitude: nil, longitude: nil)
    #authorize @addresses
    @hash = Gmaps4rails.build_markers(@addresses) do |address, marker|
      marker.lat address.latitude
      marker.lng address.longitude
      marker.infowindow infobox(address)
    end
  end

  def infobox(address)
    "<div><b>Name:</b> #{address.user.first_name.capitalize} #{address.user.last_name.capitalize}</div>
    <div><b>Email:</b> #{address.user.email}</div>
    <div><b>Role:</b> #{check_role(address.user).capitalize}</div>
    <div><b>Address:</b> #{address.street_address}</div>"
  end

end
