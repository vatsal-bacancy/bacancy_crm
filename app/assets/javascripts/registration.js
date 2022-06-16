// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks

//= require jquery.min.js
//= require bootstrap.min.js

//= require bootstrap-datepicker.min.js
//= require cocoon

//= require cosmos.min.js




$(document).ready(function(){
	$(".flash-messages").delay(2000).slideUp(1000).fadeOut();
	$(".navbar-toggler").click(function(){
		$('body').toggleClass('layout-left-sidebar-collapsed');
	})
	   $("li").click(function(e){
	   	    e.preventDefault();
     		$(this).toggleClass("open");
     		$(this).find('ul').toggleClass('collapse in');

 	    // active class add and remove  //

 	    	 $('li').removeClass("active");
            $(this).addClass("active");

    });

});
