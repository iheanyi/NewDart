# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :course do
    course_number "MyString"
    title "MyString"
    credits ""
    department nil
  end
end
