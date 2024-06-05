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

## Usage

Add the following to your Gemfile:

```ruby
gem "tabulard", require: "sheetah/frozen"
```

Then `bundle install`.

For examples of common use cases, please have a look at `spec/sheetah_spec.rb`.

## Project status

Tabulard already works pretty well but is still under active
development.

It started as a fork of [Sheetah](https://github.com/steeple-org/sheetah),
a library used in production at Steeple and originally authored by the
now-maintainer of Tabulard.

For now, Tabulard aims to stay mostly retrocompatible with Sheetah. That
said, retrocompatibility is not a long-term goal of Tabulard, as its
roadmap will eventually bring important changes that can't be compatible
with Sheetah (such as renaming the top-level Ruby module, for example).
