# frozen_string_literal: true

# :nocov: #

require_relative "../tabulard"

Tabulard::Types::Type.all(&:freeze)

# :nocov: #
