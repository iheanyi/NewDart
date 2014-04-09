class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.string :name
      t.string :tag

      t.timestamps
    end
  end
end
