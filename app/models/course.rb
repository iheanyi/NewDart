class Course < ActiveRecord::Base
  belongs_to :department, :counter_cache => true
  belongs_to :term
end
