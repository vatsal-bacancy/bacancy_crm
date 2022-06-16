class FieldsController < ApplicationController

  def new
    @group = Group.find(params[:group_id])
    @klass = Klass.find(params[:klass_id])
    @field = Field.new
  end

  def create
    ActiveRecord::Base.transaction do
      begin
        field = Field.build(field_params)
        if field.save
          field.create_column
          @klass = field.klass
          if Field::CLASS_MAP[field.klass.constant] # create column in opposite model, see field.rb for more info
            klass = Klass.find_by(name: Field::CLASS_MAP[field.klass.constant].name)
            field = Field.build(field_params.merge({group_id: Group.find_by(default: true, klass: klass).id, klass_id: klass.id}))
            field.save
            field.create_column
          end
          flash[:notice] = "Successfully created"
        else
          flash[:danger] = field.errors.full_messages.join(",")
        end
      rescue => e
      end
    end
  end

  def edit
    @group = Group.find(params[:group_id])
    @klass = @group.klass
    @field = Field.find(params[:id])
    respond_to do |f|
      f.js {render "new"}
    end
  end

  def update
    @field = Field.find(params[:id])
    @klass = @field.klass
    @field.update_attributes(field_params)
  end

  def destroy
    ActiveRecord::Base.transaction do
      begin
        field = Field.find(params[:id])
        @klass = field.klass
        field.group.fields.where(klass: @klass).where('position > (?)', field.position).each { |field| field.update(position: field.position - 1) }
        field.user_field_preferences.each { |user_field_preference| user_field_preference.make_invisible_in_table } # To reorder it, TODO: Also this should move to destroy callback
        if field.destroy
          field.destroy_column
        end
      rescue => e
      end
    end
  end

  def change_position
    ActiveRecord::Base.transaction do
      begin
        @klass = Klass.find(params[:klass_id])
        group = Group.find(params[:group_id])
        params[:field_ids].each_with_index do |field_id, position|
          Field.find(field_id).update(position: position, group: group)
        end
      rescue => e
      end
    end
    @groups = @klass.groups.includes(:fields)
  end

  def change_position_in_table
    ActiveRecord::Base.transaction do
      begin
        klass = Klass.find(params[:klass_id])
        field = Field.find(params[:field_id])
        details = params[:details]
        from = details[:from].to_i
        to = details[:to].to_i
        if from > to
          current_user.field_preferences_of_klass(klass: klass)
            .where('position_in_table >= ? AND position_in_table < ?', to, from)
            .each do |field_preference|
            field_preference.update(position_in_table: field_preference.position_in_table + 1)
          end
        elsif to > from
          current_user.field_preferences_of_klass(klass: klass)
            .where('position_in_table > ? AND position_in_table <= ?', from, to)
            .each do |field_preference|
            field_preference.update(position_in_table: field_preference.position_in_table - 1)
          end
        end
        field.user_preference(user: current_user).update(position_in_table: to)
      rescue => e
      end
    end
  end

  def toggle_visible_in_table
    @klass = Klass.find(params[:klass_id])
    @field = Field.find(params[:field_id])
    if params[:visible_in_table] == "true"
      @field.user_preference(user: current_user).make_visible_in_table
    else
      @field.user_preference(user: current_user).make_invisible_in_table
    end
  end

  # TODO: Maybe this is useless
  def change_header_view
  end

  def change_properties
    @field = Field.find(params[:id])
    @field.update_attribute(params[:property_name], !@field.send(params[:property_name]))
    flash[:alert] = "Field #{@field.name}'s property was changed"
  end

  private

  def field_params
    params.require(:field).permit(:name, :label, :column_type, :klass_id, :position, :placeholder, :min_length, :max_length, :default_value, :required, :quick_create, :key_field_view, :visible_in_table, :mass_edit, :group_id)
  end

end
