# frozen_string_literal: true

SimpleCov.start do
  root ENV.fetch("ENGINE_ROOT", nil)

  add_filter "lib/decidim/direct_verifications/tests"
  add_filter "lib/decidim/direct_verifications/version.rb"
  add_filter "/spec"
end

SimpleCov.command_name ENV.fetch("COMMAND_NAME", nil) || File.basename(Dir.pwd)

SimpleCov.merge_timeout 1800
