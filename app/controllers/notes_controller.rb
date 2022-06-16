class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_klass

  def new
    @note = Note.new(noteable_type: params[:noteable_type], noteable_id: params[:noteable_id])
    @klass = Klass.find_by(name: "Note")
    @groups = Group.includes(:fields).where(klass: @klass)
  end

  def create
    @note = Note.new(note_pramas)
    @note_klass = Klass.find_by(name: "Note")
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
    if @note.noteable_type == "Lead"
      @object = Lead.find(@note.noteable_id)
    elsif @note.noteable_type == "Client"
      @object = Client.find(@note.noteable_id)
    end
    if @note.save
      create_document(@note, params[:document_ids], params[:attachments],current_user)
      flash[:success] = 'Note Successfully Added!'
    else
      flash[:danger] = @note.errors.full_message.join(",")
    end
    @note_show = Note.new
  end

  def index
    @from_page = 'index'
    if params[:noteable_type] == "Lead"
      @object = Lead.find(params[:noteable_id])
    elsif params[:noteable_type] == "Client"
      @object = Client.find(params[:noteable_id])
    end
    @note_klass = Klass.find_by(name: "Note")
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
  end

  def show
    @note = Note.find(params[:id])
    @klass = Klass.find_by(name: "Note")
    @fields = current_user.fields_for_table_with_order(klass: @klass)
    @object = @note.noteable
  end

  def edit
    @note = Note.find(params[:id])
    @note_klass = Klass.find_by(name: "Note")
    @groups = Group.includes(:fields).where(klass: @note_klass)
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
    if @note.noteable_type == "Lead"
      @object = Lead.find(@note.noteable_id)
    elsif @note.noteable_type == "Client"
      @object = Client.find(@note.noteable_id)
    end
  end

  def update
    @note = Note.find(params[:id])
    @note_klass = Klass.find_by(name: "Note")
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
    if @note.noteable_type == "Lead"
      @object = Lead.find(@note.noteable_id)
    elsif @note.noteable_type == "Client"
      @object = Client.find(@note.noteable_id)
    end
    if @note.update(note_pramas)
      create_document(@note, params[:document_ids], params[:attachments],current_user)
      flash[:success] = 'Note Successfully Updated!'
    else
      flash[:danger] = @note.errors.full_message.join(",")
    end
    @note_show = Note.new
  end

  def destroy
    @note = Note.find(params[:id])
    @note_klass = Klass.find_by(name: "Note")
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
    if @note.noteable_type == "Lead"
      @object = Lead.find(@note.noteable_id)
    elsif @note.noteable_type == "Client"
      @object = Client.find(@note.noteable_id)
    end
    if @note.destroy
      flash[:success] = 'Note Successfully Deleted!'
    else
      flash[:danger] = @note.errors.full_message.join(",")
    end
    @note_show = Note.new
  end

  def destroy_all
    @notes = Note.where(id: params[:ids])
    if params[:noteable_type] == "Lead"
      @object = Lead.find(params[:noteable_id])
    elsif params[:noteable_type] == "Client"
      @object = Client.find(params[:noteable_id])
    end
    if @notes.destroy_all
      flash[:success] = 'Selected Notes Successfully Deleted!'
    else
      flash[:danger] = 'Something Went Wrong While Deleting Selected Notes!'
    end
    @notes = Note.all
    @note_klass = Klass.find_by(name: "Note")
    @note_show = Note.new
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
  end

  def back_to_note
    @note = Note.find(params[:id])
    if @note.noteable_type == "Lead"
      @object = Lead.find(@note.noteable_id)
    elsif @note.noteable_type == "Client"
      @object = Client.find(@note.noteable_id)
    end
    @note_klass = Klass.find_by(name: "Note")
    @note_fields = current_user.fields_for_table_with_order(klass: @note_klass)
  end

  private
  def note_pramas
    params.require(:note).permit(:content, :attachment, :noteable_type, :noteable_id, multi_select_params_permit(@klass)).merge(user_id: current_user.id)
  end

  def set_klass
    @klass = Klass.find_by(name: 'Note')
    @data = {}
    fields = Field.where(klass: @klass, have_custom_value: true)
    fields.each do |field|
      @data[field.name.to_sym] = field.field_picklist_values.pluck(:value)
    end
  end
end
