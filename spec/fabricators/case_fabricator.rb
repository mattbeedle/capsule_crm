Fabricator(:case, class_name: :'CapsuleCRM::Case') do
  name { Faker::Lorem.sentence }
  party { Fabricate.build(:person) }
end
