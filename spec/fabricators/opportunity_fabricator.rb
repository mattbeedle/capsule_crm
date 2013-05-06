Fabricator(:opportunity, class_name: :'CapsuleCRM::Opportunity') do
  name          'Test'
  milestone_id  1
  party_id      { rand(10) }
end
