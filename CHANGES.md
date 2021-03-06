## 0.1.7 (28 April 2016)

- The default `to_s` for `TypesafeEnum::Enum` now includes the enum's class, key, value,
  and ordinal, e.g.

      Suit::DIAMONDS.to_s
      # => "Suit::DIAMONDS [1] -> diamonds"

  (Fixes [#5](https://github.com/dmolesUC3/typesafe_enum/issues/5).)
- `::find_by_value_str` now uses a hash lookup like the other `::find_by` methods.
- Improved method documentation.

## 0.1.6 (15 Mar 2016)

- [#3](https://github.com/dmolesUC3/typesafe_enum/pull/3) - No need for `instance_eval`
  when creating new enum instance methods - [@dblock](https://github.com/dblock).

## 0.1.5 (27 Jan 2016)

- Include the original call site in the warning message for duplicate instances to help
  with debugging.
- Modified gemspec to take into account SSH checkouts when determining the homepage URL.

## 0.1.4 (18 Dec 2015))

- Exact duplicate instances (e.g. due to multiple `requires`) are now ignored with a warning,
  instead of causing a `NameError`. Duplicate keys with different values, and duplicate values
  with different keys, still raise a `NameError`.
- `NameErrors` due to invalid keys or values no longer cause the enum class to be undefined.
  However, the invalid instances will still not be registered and no constants created for them.

## 0.1.3 (17 Dec 2015)

- Fixed issue where invalid classes weren't properly removed after duplicate name declarations,
  polluting the namespace and causing duplicate declration error messages to be lost.

## 0.1.2 (19 Nov 2015)

- Fixed issue where `::find_by_value_str` failed to return `nil` for bad values

## 0.1.1 (19 Nov 2015)

- Added `::find_by_value_str`

## 0.1.0 (18 Nov 2015)

- Initial release
