class Renderer::AjaxDatatable

  def render(id:, url:, fields:, default_search:)
    fields = fields.map{ |field| field.with_indifferent_access }
    default_search = default_search.with_indifferent_access
    ApplicationController.render partial: 'renderer/ajax_datatable/table', locals: { id: id,
                                                                                     url: url,
                                                                                     fields: fields,
                                                                                     default_search: default_search_options(fields, default_search) }
  end

  def default_search_options(fields, default_search)
    fields.map do |field|
      {search: default_search[field[:name]]} if default_search[field[:name]]
    end
  end
end
