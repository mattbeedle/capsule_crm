Fabricator(:case, class_name: :'CapsuleCRM::Case') do
  name { Faker::Lorem.sentence }
end
