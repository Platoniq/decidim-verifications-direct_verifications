# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/direct_verifications/version"

Gem::Specification.new do |s|
  s.version = Decidim::DirectVerifications::VERSION
  s.authors = ["Ivan Vergés"]
  s.email = ["ivan@platoniq.net"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/Platoniq/decidim-verifications-direct_verifications"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-direct_verifications"
  s.summary = "A decidim batch direct registration and verification module"
  s.description = "Provides a verification method that also registers users directly in the platform. Can be used to mass verificate user with other verification handlers"

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "package.json", "Rakefile", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "decidim-admin", Decidim::DirectVerifications::MIN_DECIDIM_VERSION
  s.add_dependency "decidim-core", Decidim::DirectVerifications::MIN_DECIDIM_VERSION
end
