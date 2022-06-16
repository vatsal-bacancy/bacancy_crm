class ModuleNumbersController < ApplicationController
    before_action :authenticate_user!

    def index
        @module_number = ModuleNumber.new
        @module_name = ModuleNumber.all
        @klass_names = Klass.pluck(:label, :id)
        #@module_prefix = ModuleNumber.first.module_prefix
        #render json: @module_number
    end

    def update
        @module_data = ModuleNumber.find(params[:id])
        @module_data.update(update_data_model)
    end

    def get_module_name
        @module_number = ModuleNumber.find_by(klass_id: params[:klass_id])
        respond_to do |format|
            format.js
        end
        #render json: @module_number
    end

    private
    def update_data_model
        params.require(:module_number).permit(:module_prefix, :sequence_start, :klass_id)
    end
end
