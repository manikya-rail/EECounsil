const initCalender  = function(events) {
  $(".calendar").fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    selectable: false,
    selectHelper: true,
    editable: false,
    eventLimit: false,
    displayEventTime: false,
    events: events,
    // eventColor: color,
    eventClick: function(event, jsEvent, view) {
      date = new Date(event.schedule_date).toDateString();
      start = event.starts_at.substr(11,5)
      end = event.ends_at.substr(11,5)
      $('#modalTitle').html('Schedule');
      // if (event.status == 'booked') {
      //   $('#modalStatusBooked').html(booked);
      // }else {
      //   $('#modalStatusCancelled').html('cancelled');
      // }
      $('#modalBody').html(date);
      $('#modalTiming').html(start+" to "+end);
      $('#therapist').html(event.therapist);
      $('#patient').html(event.patient);
      $('#eventUrl').attr('href', event.url);
      $('#calendarModal').modal();
    },
    eventRender: function(event, element) {
        if (event.status == 'booked') {
            element.css({
                'background-color': '#0a74ba',
                'border-color': '#0a74ba'
            });
        }
        else if (event.status == 'canceled') {
            element.css({
                'background-color': '#fe0106',
                'border-color': '#fe0106'
            });
        }
        else if (event.status == 'completed') {
            element.css({
                'background-color': '#1aa732',
                'border-color': '#1aa732'
            });
        }
        else if (event.status == 'scheduled') {
            element.css({
                'background-color': '#FFC733',
                'border-color': '#FFB533'
            });
        }
    }
  });

  $(".fc-left").append('<select class="select_status btn btn-default">' +
                        '<option value="">All</option>'+
                        '<option value="scheduled">Scheduled</option>'+
                        '<option value="booked">Booked</option>'+
                        '<option value="canceled">Canceled</option>'+
                        '<option value="completed">Completed</option>'+
                        '</select>');

  $(".select_status").on("change", function() {
    var s = this.value
     $.ajax({
      type: "GET",
      url: "/schedules",
      data: { status : s},
      success: function(data) {
        for(i = 0; i < data.length; i++){
          data[i].start = data[i].schedule_date
          data[i].end = data[i].schedule_date
          data[i].title = data[i].starts_at.substr(11,5) + " to " + data[i].ends_at.substr(11,5)
        }
        $('.calendar').fullCalendar('removeEvents');
        $('.calendar').fullCalendar('addEventSource', data);
      },
      dataType: "json"
    });
  });
}

const initializeCalendar = function() {
  $.ajax({
        type: "GET",
        url: "/schedules",
        success: function(data) {
        // console.log(data,"dfds")
        //initCalender(data)
          initCalender()
        },
        dataType: "json"
      });
};
$(document).ready(initializeCalendar);