# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim-direct_verifications", path: "."

gemspec

group :development, :test do
  gem "bootsnap"
  gem "byebug", "~> 10.0", platform: :mri
end

group :development do
  gem "faker", "~> 1.9"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 3.5"
end
