[![Build
Status](https://travis-ci.org/mattbeedle/capsule_crm.png)](https://travis-ci.org/mattbeedle/capsule_crm)
[![Code
Climate](https://codeclimate.com/github/mattbeedle/capsule_crm.png)](https://codeclimate.com/github/mattbeedle/capsule_crm)
[![Gem
Version](https://badge.fury.io/rb/capsule_crm.png)](http://badge.fury.io/rb/capsule_crm)
[![Coverage
Status](https://coveralls.io/repos/mattbeedle/capsule_crm/badge.png?branch=master)](https://coveralls.io/r/mattbeedle/capsule_crm)
[![Dependency
Status](https://gemnasium.com/mattbeedle/capsule_crm.png)](https://gemnasium.com/mattbeedle/capsule_crm)
[![Stories in
Ready](http://badge.waffle.io/mattbeedle/capsule_crm.png)](http://waffle.io/mattbeedle/capsule_crm)
[![Gitter
chat](https://badges.gitter.im/mattbeedle/capsule_crm.png)](https://gitter.im/mattbeedle/capsule_crm)
[![tip for next
commit](https://tip4commit.com/projects/1022.svg)](https://tip4commit.com/github/mattbeedle/capsule_crm)

# CapsuleCRM

CapsuleCRM provides an ActiveModel compliant interface to the
[capsulecrm.com](http://capsulecrm.com) API

## Installation

Add this line to your application's Gemfile:

    gem 'capsule_crm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capsule_crm

## Getting Started

You need to configure CapsuleCRM with your API Token and subdomain before you
can make any requests to it. If you are using rails then you can put this into
your config/initializers folder.
```ruby
CapsuleCRM.configure do |config|
  config.api_token       = 'API Token here'
  config.subdomain       = 'your capsule crm company subdomain here'

  # Optional
  config.logger          = your_logger # default is Logger.new(STDOUT)
  config.perform_logging = true # default is false
end
```

## Usage

### Parties
```ruby
# List Parties
CapsuleCRM::Party.all

# With query parameters
CapsuleCRM::Party.all(
  q: 'search term here', email: 'email to search for here',
  lastmodified: 6.weeks.ago, tag: 'tag to search for here',
  start: 10, limit: 55
)

# Find one
# When the party is an organization this returns a CapsuleCRM::Organization
# otherise it returns a CapsuleCRM::Person
party = CapsuleCRM::Party.find(ID)
```

### People
```ruby
# Find a person
person = CapsuleCRM::Person.find(ID)

# List People
CapsuleCRM::Person.all

# Initialize a new person
person = CapsuleCRM::Person.new(first_name: 'Matt', last_name: 'Beedle')

# Validate a person
person.valid?

# Save a person
person.save

# Update a person
person.update_attributes first_name: 'John'

# Create a Person
person = CapsuleCRM::Person.create(first_name: 'Matt', last_name: 'Beedle')

# Get organization associated with a person
person.organization

# Delete a person
person.destroy

# List opportunities
person.opportunities

# List tags
person.tags

# Add a tag
person.add_tag 'a test tag'

# View history
person.histories

# Build a new history item
history_item = person.histories.build note: 'a note'

# Create a new history item
history_item = person.histories.create note: 'a note'
```

### Organizations
```ruby
# Find an organization
organization = CapsuleCRM::Organization.find(ID)

# List Organizations
CapsuleCRM::Organization.all

# Initialize a new organization
org = CapsuleCRM::Organization.new(name: 'Vegan.io')

# Validate an organization
org.valid?

# Save an organization
org.save

# Update an organization
org.update_attributes name: 'Apple Inc'

# Create an organization
org = CapsuleCRM::Organization.create(name: 'Vegan.io')

# Get people for an organization
org.people

# Delete an organization
org.destroy

# List opportunities
org.opportunities

# List tags
org.tags

# Add a tag
org.add_tag 'a test tag'

# View history
org.histories

# Build a new history item
history = org.histories.build note: 'some note text'

# Create a new history item
history = org.histories.create note: 'some note text'
```

### Contacts

People and organizations may both have contacts. Contacts consist of emails,
phones, websites and addresses.

```ruby
person.contacts
# => CapsuleCRM::Contacts

# Assign an array of CapsuleCRM::Email objects
person.contacts.emails =
  [CapsuleCRM::Email.new(email_address: 'test@test.com', type: 'Work')]

# Assign an array of email attributes
person.contacts.emails = [{ email_address: 'test@test.com', type: 'Work' }]

# Add a new email
person.contacts.emails << CapsuleCRM::Email.new(email_address: 'test@test.com')

# person.emails delegates to person.contacts.emails so the above code may be
# shortened to:

person.emails =
  [CapsuleCRM::Email.new(email_address: 'test@test.com', type: 'Work')]

# Assign an array of email attributes
person.emails = [{ email_address: 'test@test.com', type: 'Work' }]

person.emails << CapsuleCRM::Email.new(email_address: 'test@test.com')

# The above syntax is exactly the same for addresses, websites and phones.
```

### Tracks
```ruby
# Find a track
Track = CapsuleCRM::Track.find(ID)

# List tracks
tracks = CapsuleCRM::Track.all
```

### Opportunities
```ruby
# Find an opportunity
opportunity = CapsuleCRM::Opportunity.find(ID)

# List all opportunities
opportunities = CapsuleCRM::Opportunity.all

# Build a new opportunity
opportunity = CapsuleCRM::Opportunity.new(
  name: 'my first opportunity',
  party: CapsuleCRM::Party.find(1)
  milestone: CapsuleCRM::Milestone.find(10)
  track: CapsuleCRM::Track.all.first
)

# Save the opportunity
opportunity.save
opportunity.save!

# List tags
opportunity.tags

# Add a tag
opportunity.add_tag 'tag here'

# View history
opportunity.histories

# Build a new history item
history = opportunity.histories.build note: 'some note text'

# Create a new history item
history_item = opportunity.histories.create note: 'some text here'
```

### Cases
```ruby
# Find a case
kase = CapsuleCRM::Case.find(ID)

# List Cases
kase = CapsuleCRM::Case.all

# Update a Case
kase.update_attributes status: 'CLOSED'

# Delete a Case
kase.destroy

# List tags
kase.tags

# Add a tag
kase.add_tag 'A test tag'

# View history
kase.histories

# Build a new history
history = kase.histories.build note: 'note text here'

# Create a new history item
history_item = kase.histories.create note: 'another note'
```

### History
```ruby
# Find a history item
history_item = CapsuleCRM::History.find(ID)

# Get the party
history_item.party

# Get the case
history_item.case

# Get the opportunity
history_item.opportunity

# Update a history item
history_item.update_attributes note: 'some new note text'

# Delete a history item
history_item.destroy
```

### Tasks
```ruby
# List open tasks
tasks = CapsuleCRM::Task.all

# Query open tasks
tasks = CapsuleCRM::Task.all(
  category: 'category name', user: 'username', start: 6, limit: 25
)

# Add a task
CapsuleCRM::Task.create(
  description: 'task description', due_date: Date.tomorrow
)

# Update task
task.update_attributes description: 'a new improved task description'

# Delete a task
task.destroy

# Complete a task
task.complete

# Reopen a task
task.reopen

# List available task categories
CapsuleCRM::Task.categories
```

### Users
```ruby
# List all users
CapsuleCRM::User.all

# Find a user by username
user = CapsuleCRM::User.find_by_username('username here')
```

### Countries
```ruby
# List all countries
CapsuleCRM::Country.all
```

### Currencies
```ruby
# List all currencies
CapsuleCRM::Currency.all
```

## Supported Rubies

2.0.x, 2.1.x

## Versioning

This project follows [semver](http://semver.org/spec/v2.0.0.html) so there will
be no breaking changes in minor/patch version changes.

## Feedback

Please use github issues to give feedback. If you have a bug to report then an
accompanying failing test would be great. Extra points for a full pull request
with fix.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributers

Many thanks to the following contributers:

- [@srbaker](https://github.com/srbaker)
- [@clod81](https://github.com/clod81)
- [@danthompson](https://github.com/danthompson)
- [@ryanbooker](https://github.com/ryanbooker)
- [@ghiculescu](https://github.com/ghiculescu)
- [@whitecl](https://github.com/whitecl)
- [@jonathansimmons](https://github.com/jonathansimmons)

## Alternatives

- [placebo](https://github.com/adrianpike/placebo)
- [capsulecrm](https://github.com/ahmedrb/capsulecrm) - most active fork seems
  to be [here](https://github.com/theodi/capsulecrm)

## Donations

CapsuleCRM gem is completely free and open source.
However, if you would like to tip me for the hours I put in, you would of course
be very welcome to send Bitcoins to 1EcMFGtrw97qA3VXnQwM2Me5ruEkapCVio

## License

Copyright (c) 2013-2014 Matthew Beedle

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
