// TODO: implement options passing from HTML (like simple_datatable.js)
ajaxDatatable = {
  init: function(table) {
    let dataTable = table.DataTable({
      dom: 'lfrtip',
      lengthMenu: [50, 100],
      stateSave: true,
      stateDuration: -1,
      serverSide: true,
      processing: true,
      ajax: table.attr('data-ajax-datatable-url'),
      columnDefs: [
        { orderable: false, searchable: false, targets: [0, 1] },
      ],
      searchCols: [null, null].concat(table.attr('data-ajax-datatable-default-search').deserialize),
      order: [],
      columns: [{data: "checkbox-column"}, {data: "action-column"}].concat(table.attr('data-ajax-datatable-fields').deserialize),
      drawCallback: function() {
        this.find('[data-ajax-datatable-field-value]').on('click', function() {
          $(this).hide();
          $(this).closest('[data-ajax-datatable-field-form]').find('[data-ajax-datatable-field-editor]').show();
        });
        this.find('[data-ajax-datatable-field-editor]').on('blur change.select2', function() {
          let form = $(this).closest('[data-ajax-datatable-field-form]');
          $.ajax({
            url: form.attr('action'),
            beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
            method: 'PATCH',
            data: form.serialize(),
            success: function() {
              // TODO: this can be replaced by
              //  `$(document).trigger('ajax-datatable:reload');`
              //  or we can build ajaxDatatableManager to reload specific table
              dataTable.ajax.reload(null, false);
            }
          });
        });
      },
      initComplete: function() {
        // to fix searchDelay issue
        $('div.dataTables_filter input').off('keyup.DT input.DT');
        let searchDelay = null;
        $('div.dataTables_filter input').on('keyup', function() {
          let search = $('div.dataTables_filter input').val();
          clearTimeout(searchDelay);
          searchDelay = setTimeout(function() {
            if (search != null) {
              table.DataTable().search(search).draw();
            }
          },500);
        });
      }
    });
    this.yadcfWrapper.init(dataTable);
  },
  yadcfWrapper: {
    init: function(dataTable) {
      yadcf.init(dataTable, [{
        column_selector: '[data-ajax-datatable-column-type="Picklist"]',
        filter_type: 'multi_select',
        select_type: 'select2',
        sort_as: 'none',
        select_type_options: { theme: 'bootstrap', width: 'resolve', dropdownAutoWidth: true }
      }, {
        column_selector: '[data-ajax-datatable-column-type="DateTime"]',
        filter_type: 'range_date',
        datepicker_type: 'bootstrap-datepicker'
      }, {
        column_selector: '[data-ajax-datatable-column-type="Date"]',
        filter_type: 'range_date',
        datepicker_type: 'bootstrap-datepicker'
      }, {
        column_selector: '[data-ajax-datatable-column-type="Text"]',
        filter_type: 'text',
        filter_delay: 500
      }]);
    },
  }
};

$(document).on('ajax-datatable:reload', function() {
  $('[data-ajax-datatable]').each(function(i, table) {
    $(table).DataTable().destroy();
    ajaxDatatable.init($(table));
  });
});

// TODO: Use turbolinks instead
// $(document).on('turbolinks:load', function() {
//   $(document).trigger('ajax-datatable:reload');
// });
