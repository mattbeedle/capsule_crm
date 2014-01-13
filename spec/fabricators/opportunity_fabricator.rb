Fabricator(:opportunity, class_name: :'CapsuleCRM::Opportunity') do
  name          'Test'
  milestone_id  1
  party         { Fabricate.build(:person, id: Random.rand(1..10)) }
end
