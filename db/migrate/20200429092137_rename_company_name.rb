class RenameCompanyName < ActiveRecord::Migration[5.1]
  def up
    Company.first.update(name: 'iPos') if Company.any?
  end
  def down
    Company.first.update(name: 'Quick Net Soft') if Company.any?
  end
end
