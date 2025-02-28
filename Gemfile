# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/direct_verifications/version"

gem "decidim", Decidim::DirectVerifications::DECIDIM_VERSION
gem "decidim-direct_verifications", path: "."

gem "bootsnap", "~> 1.4"

gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

gem "faker"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", Decidim::DirectVerifications::DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "mdl"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "coveralls_reborn", require: false
end
