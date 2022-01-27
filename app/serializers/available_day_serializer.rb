class AvailableDaySerializer < ActiveModel::Serializer
  attributes :id, :available_date, :start_time, :end_time, :available_slots, :availablity_id

  def available_slots
    @available_slots = []
    # @unavailabilities = object.unavailabilities.order("unavailable_start_time").to_a
    # start_time = object.start_time
    # for i in 0..@unavailabilities.count-1
    #   # if start_time.strftime("%H:%M") != @unavailabilities[i].unavailable_start_time.strftime("%H:%M")
    #     # @available_slots << { start_time: start_time, end_time: @unavailabilities[i].unavailable_start_time, type: "available" }
    #   # end
    #   @available_slots << { start_time: @unavailabilities[i].unavailable_start_time , end_time: @unavailabilities[i].unavailable_end_time, type: "unavailable" }
    #   # start_time = @unavailabilities[i].unavailable_end_time
    # # end
    # # if start_time.strftime("%H:%M") != object.end_time.strftime("%H:%M")
    #   # @available_slots << { start_time: start_time, end_time: object.end_time, type: "available" }
    # # end
    available_slots = object.available_slots.order('start_time')
    available_slots.each do |available_slot|
      slot = get_slot(available_slot)
      if slot.present?
        @available_slots << {id: slot.id,start_time:  slot.start_time, end_time: slot.end_time, type: slot.status}
      end
    end
    @available_slots
  end

  def get_slot(slot)
    current_date = Time.now.utc.to_date
    current_time = Time.now.utc.strftime('%H:%M')
    return slot if slot.start_time.to_date > current_date
    return slot if slot.start_time.strftime('%H:%M') >= current_time
  end
end

