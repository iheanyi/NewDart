class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :tag
      t.string :name

      t.timestamps
    end
  end
end
