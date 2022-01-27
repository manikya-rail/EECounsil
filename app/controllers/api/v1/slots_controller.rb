class Api::V1::SlotsController < ApplicationController
	def index
		if params[:slot_id]
			@slot = AvailableSlot.includes([:available_day, :therapist, :availablity]).find_by_id(params[:slot_id]).to_json(include: [:available_day, :therapist, :availablity])
		else
			@slot = AvailableSlot.all
		end
		render :json => @slot
	end
	def destroy
		@slot = AvailableSlot.find_by_id(params[:id])
		@available_slots = []
		res = {response: false}
		if @slot
			@available_day = @slot.available_day
			@slot.destroy 
			@available_day.available_slots.order('start_time').each do |slot|
      			@available_slots << {id: slot.id,start_time:  slot.start_time.strftime("%I:%M %p"), end_time: slot.end_time.strftime("%I:%M %p"), type: slot.status}
      		end
			res = {response: true}
      	end
      	res[:slots] = @available_slots
      	render json: res
	end
end
