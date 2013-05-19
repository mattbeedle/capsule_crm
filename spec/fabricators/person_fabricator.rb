Fabricator(:person, class_name: :'CapsuleCRM::Person') do
  first_name { Faker::Name.first_name }
end
