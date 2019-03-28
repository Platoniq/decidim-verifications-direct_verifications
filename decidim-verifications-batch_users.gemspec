# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/verifications/batch_users/version"

Gem::Specification.new do |s|
  s.version = Decidim::Verifications::BatchUsers.version
  s.authors = ["Ivan Vergés"]
  s.email = ["ivan@platoniq.net"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/Platoniq/decidim-verifications-batch_users"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-verifications-batch_users"
  s.summary = "A decidim batch user registration and verification module"
  s.description = "Provides a verification method that also registers users directly in the platform."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  DECIDIM_VERSION= ">= 0.17.0"
  s.add_dependency "decidim-core", DECIDIM_VERSION
end
