class Field

  class SqlExecutor
    def initialize(model)
      @model = model
    end

    def create_column(name:, type:)
      @model.connection.add_column(@model.table_name, name, type)
      @model.reset_column_information
    end

    def destroy_column(name:)
      @model.connection.remove_column(@model.table_name, name)
      @model.reset_column_information
    end
  end
end
