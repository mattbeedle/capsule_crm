# Changelog

## 1.9.0

- CapsuleCRM::Errors::RecordInvalid#to_s and #inspect methods are now more
  descriptive [#78](https://github.com/mattbeedle/capsule_crm/pull/78)

## 1.8.0

- Custom fields may now be deleted.
  [#77](https://github.com/mattbeedle/capsule_crm/pull/77)

## 1.7.0

- Inspecting items only displays their attributes now. Much cleaner for working
  on the console
  [https://github.com/mattbeedle/capsule_crm/commit/cde082c1934ff97b6fa2dc9c56a01ca771d73b26](https://github.com/mattbeedle/capsule_crm/commit/cde082c1934ff97b6fa2dc9c56a01ca771d73b26)

## 1.6.2

- Fix bug where responses errors always had a blank body.
  [#76](https://github.com/mattbeedle/capsule_crm/pull/76)

## 1.6.1

- Fix issue where if capsulecrm.com returned a blank error response the
  ResponseError would raise an undefined method exception.
  [#74](https://github.com/mattbeedle/capsule_crm/pull/74)

## 1.6.0

- ResponseError#to_s now return the response message from the server so errors
  are a little easier to debug.
  [#69](https://github.com/mattbeedle/capsule_crm/pull/69)

## 1.5.3

- A has many association will now accept a single object as an argument and
  coerce that object into an array.

## 1.5.2

- Fix issue with ruby 1.9.3 where incompatible OpenStruct syntax was being used.
  Also, update tests to actually use OpenStructs not hashes. (@ryanbooker)
- Fix the update path for organizations. It was missing the org.id part. (@ghiculescu)

## 1.5.1

- Add ID to email, website, address and phone models to fix bug where they were
  being duplicated every time a contactable model was saved

## 1.5.0

- Add TaskCategory
- Upgrade to latest virtus

## 1.4.0

- Fix bug with contacts, where contact details were being attached to parties as
  an array of hashes
- Added ActiveModel::Callbacks to persistence module so after_save methods may
  be added
- Used after_save method to save all embedded associations (custom fields)

## 1.3.0

- Refactored associations to allow classes to reflect on themselves in order to
  allow serialization to happen in one place
- Created a serializer to deal with all converting all objects into capsule crm
  compliant hashes
- Created CapsuleCRM::Normalizer to deal with converting capsule crm hashes into
  ActiveModel compliant hashes
- Extracted querying logic into modules
- Extracted persistence logic into modules
- Extracted deleting logic into a module
- Added CapsuleCRM::Associations::BelongsToFinder to deal with querying the
  belongs to side of associations
- Added CapsuleCRM::CustomFieldDefinitions

## 1.2.0

- Refactor associations. Now all classes know about their associations and
  associations may be queried using
  Class.associations/has_many_associations/belongs_to_associations
- Add a serializer class to deal with serializing objects into their capsule crm
  json
- Refactor to_capsule_crm in all models to use the new serializer

## 1.1.0

- Refactored connection error raising to use faraday middleware

## 1.0.1

- Raise an error when trying to call create on a not yet saved has_many
  association
- Validate numericality of ID on all models

## 1.0.0

- Using SemVer and this gem is being used in production, so bumped to version 1
- Handle 401 responses by raising a CapsuleCRM::Errors::Unauthorized error

## 0.10.1

- Automatically strformat the lastmodified param for GET requests

## 0.10.0

- Added Track support

## 0.9.1

- Refactored code for finding parties/people/organizations to make sure that
  contacts are always a CapsuleCRM::Contacts when finding a record
- Moved attributes= into a module

## 0.9.0

### New Features

- Custom field support (@srbaker, @clod81)
- Add Organization#destroy (@danthompson)

### Bug fixes

- Fixed init_collection method for when a single (#27) (@clod81)