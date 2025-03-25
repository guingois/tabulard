# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name     = "tabulard"
  spec.version  = File.read(File.expand_path("VERSION", __dir__)).chomp
  spec.authors  = ["Erwan Thomas"]
  spec.email    = ["id@maen.fr"]
  spec.license  = "Apache-2.0"
  spec.homepage = "https://github.com/tabulard/tabulard"
  spec.summary  = "A highly-customizable tabular data processor"

  spec.required_ruby_version = ">= 3.1"

  spec.metadata["source_code_uri"]   = "https://github.com/tabulard/tabulard"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/tabulard/tabulard/issues"
  spec.metadata["changelog_uri"]     = "https://github.com/tabulard/tabulard/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://github.com/tabulard/tabulard/blob/master/README.md"

  # All privileged operations by any of the owners require OTP.
  spec.metadata["rubygems_mfa_required"] = "true"

  bindir = "exe"
  libdir = "lib"

  spec.files = Dir.glob(
    [
      "#{bindir}/*",
      "#{libdir}/**/*",
      "LICENSE",
      "VERSION",
      "README.md",
    ]
  )

  spec.bindir        = bindir
  spec.executables   = spec.files.grep(%r{#{bindir}/}) { |path| File.basename(path) }
  spec.require_paths = [libdir]
end
