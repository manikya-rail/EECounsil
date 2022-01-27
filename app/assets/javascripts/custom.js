
		
$(document).ready(function(){
	
		$(window).scroll(function() {
			if ($(this).scrollTop() > 0){  
					$('.header').addClass("sticky");
				}
			else{
				$('.header').removeClass("sticky");
			}
			});
	
	
	

		$(".menu-collapser .collapse-button").click(function(){
      $('body').toggleClass('menu-open')
    });

		//menu open class
		$('.dropdown .sub-toggle').click(function () {
				$(this).siblings("ul").slideToggle('');
		});

$('.testi-sec .owl-one').owlCarousel({
				loop:true,
				margin:30,
				navText:["<i class='fa fa-long-arrow-left'></i>","<i class='fa fa-long-arrow-right'></i>"],
				nav:true,
				dots:false,
				responsive:{
						0:{
								items:1,
								nav:false,
								dots:true
						},
						767:{
								items:2
						},
						1000:{
								items:3
						}
				}
		});

	$('.bnr-btm-vdo > .centered >  a').click(function (e) {
		e.preventDefault();
		$('body').addClass('show-vid')
	});
	$('.close-vdo, .vid-overlay').click(function (e) {
		$('body').removeClass('show-vid')
	});

});

$(document).ready(function (e) {

$('.quition-inr .owl-carousel').owlCarousel({
	items: 1,
    autoHeight: true,
	loop: false,
	center: true,
	margin: 0,
	dots: false,
	mouseDrag: false,
	touchDrag: false,
	URLhashListener: true,
	autoplayHoverPause: true,
	startPosition: 'URLHash'
});

});



$('.adv-search-btn > .btn').click(function()
{
  $('.ad-search-inr').slideToggle('slow', function() {
   $(this).parent().toggleClass('btn-open');
  });
});

/*Country State City drop down */
$(document).ready(function(){
  $('#sub_btn').click(function(){
    $('.loader_img').css('display',"block")
  });
});

/*Delete user functionality by the admin*/
function delete_user(row, params){
	var result = confirm("Are you sure you want to delete?");
  if (result){
    if(params !=  "patient"){
      $.ajax({
        url: +row+"/check_schedule",
        type: "get",
        dataType: "json",
        data: "",
        success: function(data) {
          if(data.Schedule_present){
            window.location = +row+"/delete_therapist";
          }else{
            Rails.ajax({
              url: +row+"/delete_profile",
              type: "get",
              data: "",
              success: function(data) {
                window.location = "/users/index?role_name="+data.role_name;
              },
              error: function(data) {
              }
            });
          }
        },
        error: function(data) {
          console.log("bye",data);
        }
      });
    }else{
      $.ajax({
	      url: +row+"/delete_profile",
	      type: "get",
	      data: "",
	      success: function(data) {
					window.location = "/users/index?role_name="+data.role_name;
	      },
	      error: function(data) {
	      }
			});
		}
	}
  else{
    return false;
  }
 }

 /* add new course sessions.*/
function addMoreButton(e){
  timeframe_id = $(e.currentTarget).parent().parent().children(':first').find('input').attr('id').split('_')[4];
  term = $(e.currentTarget).parents('div.nested-fields').children('div.col-md-12').children('div.form-group').children('div.frm-grp-inr').find('input').length ;
  var name = "course[course_sessions_attributes]["+parseInt(timeframe_id)+"][media_attributes]["+term+"][item]";
  var id = "course_course_sessions_attributes_"+parseInt(timeframe_id)+"_media_attributes_"+term+"_item";

  $("<div class='row'><div><b>"+(term+1)+".</b></div><div class='col-md-11'><input type='file' name="+name+" id="+id+" class='form-control'></div><div class='col-md-1' closebtnDiv><a href='javascript:void(0)', onclick='check_field_new(event)' class= 'remove-field btn btn-danger fa fa-close closebtnDiv'></a></div></div>").insertBefore($(e.currentTarget));
};

function check_field_new(e){
  var media_id = $(e.currentTarget).data().id
  var current = $(e.currentTarget)
  if(current.parents('div.nested-fields').children('div.col-md-12').children('div.form-group').children('div.frm-grp-inr').find('input').length  <= 1){
    alert("Course page can't be empty click on remove course page button to remove the page.")
  }else{
    current.parent('div.col-md-1').parent('div.row').remove()
    $(e.currentTarget).remove()
  }
}


/* edit course session*/
function addMoreButtonEdit(e){
  timeframe_id = $(e.currentTarget).parent().last().find('input').attr('id').split('_')[4];
  term = $(e.currentTarget).siblings('div .col-md-12').length;
  var name = "course[course_sessions_attributes]["+parseInt(timeframe_id)+"][media_attributes]["+term+"][item]";
  var id = "course_course_sessions_attributes_"+parseInt(timeframe_id)+"_media_attributes_"+term+"_item";
  $("<div class='col-md-12'><div class='form-group'><div class='frm-grp-inr'><div class='row'><div><b>"+(parseInt(timeframe_id)+1)+"."+(term+1)+"</b></div><div class='col-md-11'><input type='file' name="+name+" id="+id+" class='form-control'></div><div class='col-md-1 closebtnDiv'><a href='javascript:void(0)', class= 'remove-field btn btn-danger fa fa-close closebtn', onclick='check_field_edit(event)'></a></div></div></div></div>").insertBefore($(e.currentTarget));
}
function check_field_edit(e){
  var current = $(e.currentTarget)
  var media_id = $(e.currentTarget).data().id
  current.parents('div.nested-fields.well').children('div.document').length
  if(current.parents('div.nested-fields').children('div.col-md-12').children('div.form-group').children('div.frm-grp-inr').find('input').length  <= 1){
    alert("Course page can't be empty click on remove course page button to remove the page.")
  }else{
    if (media_id){
      var res =  confirm("Are you sure to remove this media from page?");
      if (res) {
        $.ajax({
        url: "/courses/delete_coursesession_media",
        type: "get",
        dataType: "json",
        data: { id: media_id },
        success: function(data) {
        doc = (current.parents('div.col-md-12').first()[0].previousElementSibling)
        input  =  $("#"+current.parents('div.col-md-12').first()[0].nextElementSibling.nextElementSibling.id)
        current.parents('div.col-md-12').first()[0].remove()
        doc.remove()
        input.remove()
        },
        error: function(data) {
          console.log("bye",data);
        }
      });
      }else{
        return false;
      }
    }else{
      current.parents('div.col-md-12')[0].remove()
    }
  }
}