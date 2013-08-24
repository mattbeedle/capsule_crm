# Changelog

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