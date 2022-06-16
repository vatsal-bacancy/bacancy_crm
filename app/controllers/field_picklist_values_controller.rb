class FieldPicklistValuesController < ApplicationController
  before_action :authenticate_user!

  def index
    @klasses = Klass.pluck(:label, :id)
    @field_names = []
    if params[:field_id].present?
      @field = Field.find(params[:field_id])
      @field_names = Field.where(klass_id: @field.klass_id, column_type: ["Picklist", "Multi-Select Check Box"],  have_custom_value: true).pluck(:label, :id)
      @field_picklist_values = @field.field_picklist_values
    end
  end

  def new
    @field_picklist_value = FieldPicklistValue.new(field_id: params[:field_id])
  end

  def create
    @field_picklist_value = FieldPicklistValue.new(field_picklist_value_params)
    if @field_picklist_value.save
      @field_picklist_value.create_value_in_opposite_class
      @field = @field_picklist_value.field
      @field_picklist_values = FieldPicklistValue.where(field: @field)
    end
  end

  def change_klass
    @klass = Klass.find(params[:klass_id])
  end

  def change_field
    @field = Klass.find(params[:klass_id]).fields.field_picklist_valuable.find_by(id: params[:field_id])
    @field_picklist_values = @field.field_picklist_values
  end

  def edit
    @field_picklist_value = FieldPicklistValue.find(params[:id])
  end

  def update
    @field_picklist_value = FieldPicklistValue.find(params[:id])
    if @field_picklist_value.update_attributes(field_picklist_value_params)
      @field = @field_picklist_value.field
      @field_picklist_values = FieldPicklistValue.where(field: @field)
    end
  end

  def destroy
    @field_picklist_value = FieldPicklistValue.find(params[:id])
    @field_picklist_value.destroy
    @field = @field_picklist_value.field
    @field_picklist_values = FieldPicklistValue.where(field: @field)
  end

  def change_position
    params[:field_picklist_value_ids].each_with_index do |field_picklist_value_id, position|
      FieldPicklistValue.find(field_picklist_value_id).update(position: position)
    end
  end

  private

  def field_picklist_value_params
    params.require(:field_picklist_value).permit(:field_id, :value, :color)
  end
end
