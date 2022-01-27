$(document).ready(function(){
  $(".hide_field").each(function () {
    str = $(this).attr('id')
    str = str.replace("plan_type", "time_duration_in_hours");
    if ($(this).val() == "text")
      $('#'+ str).parent().parent().hide()
    else
      $('#'+ str).parent().parent().show()
  });
})

function planChange(e){
  str = e.target.id;
  str = str.replace("plan_type", "time_duration_in_hours");
  if (e.target.value == "text")
    $('#'+ str).parent().parent().hide()
  else
    $('#'+ str).parent().parent().show()
}
