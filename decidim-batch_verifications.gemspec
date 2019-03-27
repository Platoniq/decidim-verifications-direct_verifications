# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/batch_verifications/version"

Gem::Specification.new do |s|
  s.version = Decidim::BatchVerifications.version
  s.authors = ["Ivan Vergés"]
  s.email = ["ivan@platoniq.net"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/Platoniq/decidim-module-batch_verifications"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-batch_verifications"
  s.summary = "A decidim batch_user_registration module"
  s.description = "Provides a verification method that also registers users directly in the platform."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  DECIDIM_VERSION= ">= 0.17.0"
  s.add_dependency "decidim-core", DECIDIM_VERSION
end
