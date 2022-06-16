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
//= require jquery-ui
//= require jquery.blockUI
//= require bootstrap.min.js
//= require datatables.min
//= require dataTables.buttons.min
//= require buttons.html5.min
//= require datatable.yadcf
//= require moment.min
//= require daterangepicker.min
//= require bootstrap-datepicker.min.js
//= require timepicker.min
//= require jquery.datepair.min
//= require bootstrap-select.min.js
//= require dropzone
//= require cocoon
//= require gmaps/google
//= require select2
//= require index.js
//= require bootstrap-tagsinput
//= require cosmos.min.js
//= require cable.js
//= require croppie
//= require demo_croppie
//= require js-routes
//= require jqCron
//= require jqCron.en
//= require fullcalendar.min
//= require mustache.min
//= require bpro
//= require ajax_datatable
//= require simple_datatable
//= require Chart.bundle
//= require chartkick


// Disable click outside of bootstrap modal to close
$.fn.modal.prototype.constructor.Constructor.DEFAULTS.backdrop = 'static';


var url = window.location;
// $('ul.sidebar-menu a').filter(function() {
// return this.href == url;
// }).parent().addClass('active open');

// // for treeview
// $('ul.with-sub  a').filter(function() {
// return this.href == url;
// }).parentsUntil(".sidebar-menu > .with-sub ").addClass('active open');

var $isLinks = "";
$(document).ready(function(){
  $(".flash-messages").delay(4000).slideUp(2000).fadeOut();

  // hamburger memnu
  $(document).on('click','.sidebar-toggler', function(){
    $('body').toggleClass('layout-left-sidebar-collapsed');
  });

  // Side Ul li
  $(document).on('click','.sidebar-menu li',function(){
  $isLinks += $(this).find('a').attr('href');
          if($isLinks =='#') {
              e.preventDefault();
          }
          if($(this).hasClass('open')){
            $('li').removeClass("active open");
            $('.sidebar-submenu').removeClass("collapse in");
            $('.sidebar-submenu').addClass("collapse");
          }else{
            $('li').removeClass("active open");
            $('.sidebar-submenu').removeClass("collapse in");
            $('.sidebar-submenu').addClass("collapse");

            $(this).toggleClass("open");
            $(this).find('ul').toggleClass('collapse in');
            $(this).addClass("active");
          }   
  });

  $(document).ajaxStart($.blockUI).ajaxStop($.unblockUI);


  $( document ).ajaxStart(function() {
    $.blockUI({
      message: "<h3> Please wait... </h3>",
      css: {
        border: 'none',
        backgroundColor: '#000',
        '-webkit-border-radius': '10px',
        '-moz-border-radius': '10px',
        opacity: .5,
        color: '#fff'
      }
    });
  });

  $( document ).ajaxComplete(function() {
    $.unblockUI();
    $(".dropdown-toggle").dropdown();

  });

  // Inner  Page Tab Change
  $("#myTabs li").click(function(e){
    e.preventDefault();
    $(this).removeClass("open");
    $(this).find('ul').removeClass('collapse in');
    $('li').removeClass("active");
    $(this).removeClass("active");
  });



});
$(document).ready(function() {
  $(".dropdown-toggle").dropdown();
});


window.onload = function(){
   var viewportWidth = $(window).width();
   if (viewportWidth < 768) {
    $("body").removeClass("layout-left-sidebar-collapsed");
  }
}
$(window).resize(function () {
   var viewportWidth = $(window).width();
   if (viewportWidth < 768) {
    $("body").removeClass("layout-left-sidebar-collapsed");
  }
});

$(document).on('turbolinks:load', function(){
  $(".dropdown-toggle").dropdown();
});

function renderImages(arg) {
  if(arg.input.files){
    if(!arg.input.files.length){
      arg.onNoFiles();
    }
    else{
      arg.onFiles();
      var length = arg.input.files.length;
      for (let i = 0; i < length; i++) {
        var reader = new FileReader();
        reader.onload = function(event) {
          arg.eachFile(event.target.result, i);
        };
        reader.readAsDataURL(arg.input.files[i]);
      }
    }
  }
}

function renderItemGroup(){
  var dataToSend = $('#inventoryGroupForm').serializeArray();

  $.ajax({
    url: "/inventory_groups/setup_inventory_versions?inventory_group_id=" + $('#inventoryGroupId').val(),
    type: 'PATCH',
    data: dataToSend,
    dataType: "script"
  });
}

function selectedInventories(){
  var inventories = []
  $.each($('.deleteInventory'), function(index, element){
    if($(element).prop('checked')){
      inventories.push($(element).attr('data-id'));
    }
  });
  return inventories;
}

function manageDestroyAllDisable(){
  if(selectedInventories().length == 0){
    $('#destroy_all').addClass('pointer-disable');
  }
  else{
    $('#destroy_all').removeClass('pointer-disable');
  }
}

$(document).on('keyup', '.phone-validation', function(){
  var curchr = this.value.length;
  var curval = $(this).val();
  if (curchr == 3) {
    $(this).val("(" + curval + ") ");
  } else if (curchr == 9) {
    $(this).val(curval + "-");
  }
});

let updateCKEDITORInstances = function(){
  $.each(CKEDITOR.instances, (instance) => {
    CKEDITOR.instances[instance].updateElement();
  });
};

Bpro.events.onLoaded(function() {
  $('.timepicker').timepicker({timeFormat: 'h:i A'});
  $('.bootstrapdatepicker').datepicker({format: 'mm/dd/yyyy', todayHighlight: true, autoclose: true});
  $('.datepicker').daterangepicker({
    drops: 'auto',
    parentEl: '.modal',
    autoUpdateInput: false,
    singleDatePicker: true,
    locale: {
      format: 'MM/DD/YYYY'
    }
  });
  $('.datetimepicker').daterangepicker({
    drops: 'auto',
    parentEl: '.modal',
    autoUpdateInput: false,
    singleDatePicker: true,
    timePicker: true,
    timePickerIncrement: 15,
    locale: {
      format: 'MM/DD/YYYY hh:mm A'
    }
  });
  $('.datetimepicker').on('change', function(){
    newDate = moment($(this).val(), "MM/DD/YYYY hh:mm A")
    if (newDate.isValid()) {
      $(this).val(newDate.format("MM/DD/YYYY hh:mm A"))
    } else {
      $(this).val(this.getAttribute("value"))
    }
  })
  // TODO: added because somehow after adding `autoUpdateInput` the apply button stops working
  $('.datepicker').on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format(picker.locale.format));
    $(this).trigger('change');
  });
  $('.datetimepicker').on('apply.daterangepicker', function(ev, picker) {
    $(this).val(picker.startDate.format(picker.locale.format));
    $(this).trigger('change');
  });
  $('[data-datetimepair-container]').datepair({
    dateClass: 'datepicker',
    timeClass: 'timepicker',
    startClass: 'timestart',
    endClass: 'timeend'
  });

  $(".multi_select").select2({theme: 'bootstrap', closeOnSelect : true});
  $(".select_picker").selectpicker();
  //This fixes the issues with selectpicker (not opening while click on it)
  $('.btn.dropdown-toggle.btn-default').on('click', function() {
    $(".btn-group.bootstrap-select.form-control.select_picker").toggleClass('open');
  });
  $('.ckeditable').each(function() {
    CKEDITOR.replace($(this).attr('name'));
  });

  $('[data-google-maps-autocomplete]').each(function() {
    new google.maps.places.Autocomplete(this, {});
  });
});

$(document).on('turbolinks:load', function() {
  let hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + '"]').tab('show');
});

// Block UI for rails ujs ajax
$(document).on('ajax:beforeSend', '[data-block-ui]', function() {
  let message = $(this).attr('data-block-ui-message');
  $.blockUI({
    message: "<h3>"+ message +"</h3>",
    baseZ: 1050,
    css: {
      border: 'none',
      backgroundColor: '#000',
      '-webkit-border-radius': '10px',
      '-moz-border-radius': '10px',
      opacity: .5,
      color: '#fff'
    }
  });
});
$(document).on('ajax:complete', '[data-block-ui]', function(){
  $.unblockUI();
});
