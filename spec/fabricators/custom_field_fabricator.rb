Fabricator(:custom_field, class_name: 'CapsuleCRM::CustomField') do
  label { Faker::Lorem.word }
  tag { Faker::Lorem.word }
  text { Faker::Lorem.word }
  boolean true
  date { Date.today }
end
