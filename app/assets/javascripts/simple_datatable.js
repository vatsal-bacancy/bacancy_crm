simpleDatatable = {
  init: function(table) {
    let options = Object.assign({
      dom: 'lfrtip',
      scrollX: false,
      autoWidth: false,
      paging: true,
      pageLength: 50,
      lengthMenu: [50, 100],
      columnDefs: [
        { orderable: false, targets: '_all' },
      ],
      order: []
    }, (table.attr('data-simple-datatable-options') || '{}').deserialize);
    let dataTable = table.DataTable(options);
    this.yadcfWrapper.init(dataTable);
  },
  yadcfWrapper: {
    init: function(dataTable) {
      yadcf.init(dataTable, [{
        column_selector: '[data-simple-datatable-column-type="Picklist"]',
        filter_type: 'multi_select',
        select_type: 'select2',
        sort_as: 'none',
        select_type_options: { theme: 'bootstrap', width: 'resolve', dropdownAutoWidth: true }
      }, {
        column_selector: '[data-simple-datatable-column-type="DateTime"]',
        filter_type: 'range_date',
        datepicker_type: 'bootstrap-datepicker'
      }, {
        column_selector: '[data-simple-datatable-column-type="Date"]',
        filter_type: 'range_date',
        datepicker_type: 'bootstrap-datepicker'
      }, {
        column_selector: '[data-simple-datatable-column-type="Text"]',
        filter_type: 'text'
      }]);
    }
  }
}

$(document).on('simple-datatable:reload', function() {
  $('[data-simple-datatable]').each(function(i, table) {
    $(table).DataTable().destroy();
    simpleDatatable.init($(table));
  });
});
