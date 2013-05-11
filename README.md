[![Build
Status](https://travis-ci.org/mattbeedle/capsule_crm.png)](https://travis-ci.org/mattbeedle/capsule_crm)

[![Gem
Version](https://badge.fury.io/rb/capsule_crm.png)](http://badge.fury.io/rb/capsule_crm)

[![Coverage
Status](https://coveralls.io/repos/mattbeedle/capsule_crm/badge.png?branch=master)](https://coveralls.io/r/mattbeedle/capsule_crm)

[![Dependency
Status](https://gemnasium.com/mattbeedle/capsule_crm.png)](https://gemnasium.com/mattbeedle/capsule_crm)

# CapsuleCRM

CapsuleCRM provides an ActiveModel compliant interface to the capsulecrm API

## Installation

Add this line to your application's Gemfile:

    gem 'capsule_crm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capsule_crm

## Usage

```ruby
contacts = CapsuleCRM::Contacts.new(
  addresses:  [CapsuleCRM::Address.new(street: 'Oranieburgerstr', city: 'Berlin')],
  emails:     [CapsuleCRM::Email.new(email_address: 'mattbeedle@gmail.com')],
  phones:     [CapsuleCRM::Phone.new(phone_number: '123456789')],
  webstes:    [CapsuleCRM::Website.new(web_service: 'URL', web_address: 'http://github.com']
)

person = CapsuleCRM::Person.new(
  first_name: 'Matt', last_name: 'Beedle', organisation_name: "Matt's Company",
  contacts: contacts
)
person.save

person.first_name = 'John'
person.save #=> true

person.valid? #=> true

person.organization #=> CapsuleCRM::Organization

person.organization.tap do |org|
  org.update_attributes! contacts: CapsuleCRM::Contacts.new(
    addresses: CapsuleCRM::Address.new(street: 'Thurneysserstr')
  )

  org.contacts.phones << CapsuleCRM::Phone.new(phone_number: '234243')
  org.save
end

person.first_name = nil
person.last_name = nil
person.valid? #=> false

person.save #=> false
person.save! #=> CapsuleCRM::Errors::InvalidRecord

person.destroy #=> true

person = CapsuleCRM::Person.create(first_name: 'Matt', last_name: 'Beedle')

case = CapsuleCRM::Case.create! name: 'My First Case', party: person
case.update_attributes name: 'A New Case Name'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
