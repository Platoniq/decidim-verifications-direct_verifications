# frozen_string_literal: true

require_relative "direct_verifications/version"
require_relative "direct_verifications/user_processor"
require_relative "direct_verifications/user_stats"
require_relative "direct_verifications/verification"

module Decidim
  module DirectVerifications
    include ActiveSupport::Configurable

    # Specify in this variable which authorization methods can be managed by the plugin
    # Be careful to specify only what you really need
    config_accessor :manage_workflows do
      ["direct_verifications"]
    end
  end
end
