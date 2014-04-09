class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :course_number
      t.string :title
      t.integer :credits
      t.references :department, index: true

      t.timestamps
    end
  end
end
