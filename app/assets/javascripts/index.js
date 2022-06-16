$(function() {
  $('.btn.toggle-main').on('click', function() {
    $('.sidebar').toggleClass('is-collapsed');
    $('.content').toggleClass('is-full-width');
  });
  
   $('.btn.toggle-main2').on('click', function() {
    $('.sidebar-right').toggleClass('is-collapsed1');
    $('.content').toggleClass('is-full-width1');
  });
   $('.btn.toggle-main2').on('click', function() {
    $('body').toggleClass('overflow-x-custom');
  
  });
  
  
});


