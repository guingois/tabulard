## [Unreleased]

### Breaking changes

- Drop support for EOL Ruby versions (older than 3.1).
- `Messenger#warn` or `Messenger#error` no longer accept literal code
    strings, and only accept various kinds of `Message` instead
    (https://github.com/tabulard/tabulard/pull/1).
- Prefer Hash-based `code_data` in instances of `Message`
    (https://github.com/tabulard/tabulard/pull/3).
- `Template` and its dependent classes are no longer systematically
    frozen, and the recommended way to instantiate them is to use
    `::build` instead of `::new`
    (https://github.com/tabulard/tabulard/pull/7, https://github.com/tabulard/tabulard/pull/8).
- Values of attributes are now required by default. To mark a value as
    optional, append a `?` to the value type name in a template. The
    previous `!` suffix is no longer supported
    (https://github.com/tabulard/tabulard/pull/9).

### Features

- Support the `arm64-darwin-22` platform (https://github.com/tabulard/tabulard/pull/2).
- The value of an attribute may be specified using a Hash of options,
    instead of a single symbol
    (https://github.com/tabulard/tabulard/pull/8).

### Bugfixes

- Ignore special characters in patterns derived from headers
    (https://github.com/tabulard/tabulard/pull/5).

## [0.1.0] - 2022-04-27

- Initial release
