# Tabulard

Tabulard is a library designed to process tabular data of any kind. It
is able to handle anything that looks like a table, and currently
provides dedicated adapters for CSV documents and XSLX sheets.

It focuses on typed results and fine-grain error management, while being
performant enough to handle (very) large documents and keep a low memory
footprint.

## Documentation

The following resources document the latest valid state of the `master`
branch:

- [Ruby API](https://tabulard.github.io/tabulard/ruby)
- [Coverage](https://tabulard.github.io/tabulard/coverage)

However, the most complete and up-to-date source of information remains
the RSpec spec files. These are intended to specify the public behavior
of the library's objects. They provide numerous examples and
descriptions of how they work and how they should be used. For example,
have a look [here](spec/tabulard_spec.rb) for a general overview of the
library.

## Usage

Add the following to your Gemfile:

```ruby
gem "tabulard", require: "tabulard/frozen"
```

Then `bundle install`.

For examples of common use cases, please have a look at `spec/tabulard_spec.rb`.

## Project status

Tabulard already works pretty well but is still under active
development.

It started as a fork of [Sheetah](https://github.com/steeple-org/sheetah),
a library used in production at Steeple and originally authored by the
now-maintainer of Tabulard. For a while, Tabulard stayed compatible with
Sheetah, but it no longer is.
