$(document).ready(function(){
  $(".search_by_patient").on("change", function() {
     $.ajax({
      type: "GET",
      url: "/schedules",
      data: { id : this.value},
      success: function(data) {
        for(i = 0; i < data.length; i++){
          data[i].start = data[i].schedule_date
          data[i].end = data[i].schedule_date
          data[i].title = data[i].starts_at.substr(11,5) + " to " + data[i].ends_at.substr(11,5)
        }
        $('#select2-therapist_therapist_id-container').html("Search by Therapist");
        $('.calendar').fullCalendar('removeEvents');
        $('.calendar').fullCalendar('addEventSource', data);
      },
      dataType: "json"
    });
  });

  $(".search_by_therapist").on("change", function() {
     $.ajax({
      type: "GET",
      url: "/schedules",
      data: { id : this.value},
      success: function(data) {
        for(i = 0; i < data.length; i++){
          data[i].start = data[i].schedule_date
          data[i].end = data[i].schedule_date
          data[i].title = data[i].starts_at.substr(11,5) + " to " + data[i].ends_at.substr(11,5)
        }
        $('#select2-patient_patient_id-container').html("Search by Patient");
        $('.calendar').fullCalendar('removeEvents');
        $('.calendar').fullCalendar('addEventSource', data);
      },
      dataType: "json"
    });
  });
});
