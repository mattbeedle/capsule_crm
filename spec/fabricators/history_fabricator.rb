Fabricator(:history, class_name: :'CapsuleCRM::History') do
  note { Faker::Lorem.paragraph }
end
