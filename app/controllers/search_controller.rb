class SearchController < ApplicationController

  def index
    klass = Klass.find_by(name: 'Lead')
    @lead_fields = klass.fields.where(reference: false)
    query = ""
    @lead_fields.map{|field| query+= "#{field.name} = '#{params[:value]}' OR "}
    query.delete_suffix!(' OR ')
    @leads = Lead.where("#{query}")

  end
end
