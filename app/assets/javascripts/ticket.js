$(document).ready(function(){
  console.log("in jquery");
  return $('#ticket_organization_name_ticket').autocomplete({
    source: $('#ticket_organization_name_ticket').data('autocomplete-source')
   
  });
});