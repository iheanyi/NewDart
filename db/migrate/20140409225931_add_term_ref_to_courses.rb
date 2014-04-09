class AddTermRefToCourses < ActiveRecord::Migration
  def change
    add_reference :courses, :term, index: true
  end
end
