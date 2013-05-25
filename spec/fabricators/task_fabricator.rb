Fabricator(:task, class_name: :'CapsuleCRM::Task') do
  description { Faker::Lorem.paragraph }
  due_date { Date.tomorrow }
end
