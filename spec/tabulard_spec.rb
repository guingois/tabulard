# frozen_string_literal: true

require "tabulard"

RSpec.describe Tabulard, monadic_result: true do
  let(:types) do
    reverse_string = Tabulard::Types::Scalars::String.cast { |v, _m| v.reverse }

    Tabulard::Types::Container.new(
      scalars: {
        reverse_string: reverse_string.method(:new),
      }
    )
  end

  let(:template_opts) do
    {
      attributes: [
        {
          key: :foo,
          type: :reverse_string,
        },
        {
          key: "bar",
          type: {
            composite: :array,
            scalars: %i[
              string?
              scalar?
              email?
              scalar?
              scalar
            ],
          },
        },
      ],
    }
  end

  let(:template) do
    Tabulard::Template.build(**template_opts)
  end

  let(:template_config) do
    Tabulard::TemplateConfig.new(types: types)
  end

  let(:specification) do
    template.apply(template_config)
  end

  let(:processor) do
    Tabulard::TableProcessor.new(specification)
  end

  let(:input) do
    [
      ["foo", "bar 3", "bar 5", "bar 1"],
      ["hello", "foo@bar.baz", Float, nil],
      ["world", "foo@bar.baz", Float, nil],
      ["world", "boudiou !", Float, nil],
    ]
  end

  def process(*args, **opts, &block)
    processor.call(*args, adapter: Tabulard::Adapters::Bare, **opts, &block)
  end

  def process_to_a(*args, **opts)
    a = []
    processor.call(*args, adapter: Tabulard::Adapters::Bare, **opts) { |result| a << result }
    a
  end

  context "when there is no table error" do
    it "is a success without errors" do
      result = process(input) {}

      expect(result).to have_attributes(result: Success(), messages: [])
    end

    it "yields a commented result for each valid and invalid row" do
      results = process_to_a(input)

      expect(results).to have_attributes(size: 3)
      expect(results[0]).to have_attributes(result: be_success, messages: be_empty)
      expect(results[1]).to have_attributes(result: be_success, messages: be_empty)
      expect(results[2]).to have_attributes(result: be_failure, messages: have_attributes(size: 1))
    end

    it "yields the successful value for each valid row" do
      results = process_to_a(input)

      expect(results[0].result).to eq(
        Success(foo: "olleh", "bar" => [nil, nil, "foo@bar.baz", nil, Float])
      )

      expect(results[1].result).to eq(
        Success(foo: "dlrow", "bar" => [nil, nil, "foo@bar.baz", nil, Float])
      )
    end

    it "yields the failure data for each invalid row" do
      results = process_to_a(input)

      expect(results[2].result).to eq(Failure())
      expect(results[2].messages).to contain_exactly(
        have_attributes(
          code: "must_be_email",
          code_data: { value: "boudiou !".inspect },
          scope: Tabulard::Messaging::SCOPES::CELL,
          scope_data: { row: 4, col: "B" },
          severity: Tabulard::Messaging::SEVERITIES::ERROR
        )
      )
    end
  end

  context "when there are unspecified columns in the table" do
    before do
      input.each_index do |idx|
        input[idx] = input[idx][0..1] + ["oof"] + input[idx][2..] + ["rab"]
      end
    end

    context "when the template allows it" do
      before { template_opts[:ignore_unspecified_columns] = true }

      it "ignores the unspecified columns" do
        results = process_to_a(input)

        expect(results[0].result).to eq(
          Success(foo: "olleh", "bar" => [nil, nil, "foo@bar.baz", nil, Float])
        )

        expect(results[1].result).to eq(
          Success(foo: "dlrow", "bar" => [nil, nil, "foo@bar.baz", nil, Float])
        )
      end
    end

    context "when the template doesn't allow it" do
      before { template_opts[:ignore_unspecified_columns] = false }

      it "doesn't yield any row" do
        expect { |b| process(input, &b) }.not_to yield_control
      end

      it "returns a failure with data" do # rubocop:disable RSpec/ExampleLength
        expect(process(input) {}).to have_attributes(
          result: Failure(),
          messages: contain_exactly(
            have_attributes(
              code: "invalid_header",
              code_data: { value: "oof" },
              scope: Tabulard::Messaging::SCOPES::COL,
              scope_data: { col: "C" },
              severity: Tabulard::Messaging::SEVERITIES::ERROR
            ),
            have_attributes(
              code: "invalid_header",
              code_data: { value: "rab" },
              scope: Tabulard::Messaging::SCOPES::COL,
              scope_data: { col: "F" },
              severity: Tabulard::Messaging::SEVERITIES::ERROR
            )
          )
        )
      end
    end
  end

  context "when there are missing columns" do
    before do
      input.each do |input|
        input.delete_at(2)
        input.delete_at(0)
      end
    end

    it "doesn't yield any row" do
      expect { |b| process(input, &b) }.not_to yield_control
    end

    it "returns a failure with data" do # rubocop:disable RSpec/ExampleLength
      expect(process(input) {}).to have_attributes(
        result: Failure(),
        messages: contain_exactly(
          have_attributes(
            code: "missing_column",
            code_data: { value: "Foo" },
            scope: Tabulard::Messaging::SCOPES::TABLE,
            scope_data: nil,
            severity: Tabulard::Messaging::SEVERITIES::ERROR
          ),
          have_attributes(
            code: "missing_column",
            code_data: { value: "Bar 5" },
            scope: Tabulard::Messaging::SCOPES::TABLE,
            scope_data: nil,
            severity: Tabulard::Messaging::SEVERITIES::ERROR
          )
        )
      )
    end
  end
end
