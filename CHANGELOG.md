# Changelog

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