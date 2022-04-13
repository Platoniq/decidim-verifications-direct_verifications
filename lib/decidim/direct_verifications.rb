# frozen_string_literal: true

require_relative "direct_verifications/version"
require_relative "direct_verifications/user_processor"
require_relative "direct_verifications/user_stats"
require_relative "direct_verifications/verification"
require_relative "direct_verifications/parsers"

module Decidim
  module DirectVerifications
    include ActiveSupport::Configurable

    class InputParserError < StandardError; end

    # Specify in this variable which authorization methods can be managed by the plugin
    # Be careful to specify only what you really need
    config_accessor :manage_workflows do
      ["direct_verifications"]
    end

    # The processor for the user uploaded data where to extract emails and other info
    # be default it uses Decidim::DirectVerifications::Parsers::NameParser
    # Currently available are:
    # - :name_parser
    # - :metadata_parser
    # A custom parser can be specified as long it respects the module hierachy
    config_accessor :input_parser do
      :name_parser
    end

    # add a button to the participants list to be able to handle verifications from there
    # Manageable Verifications need to be registered in :manage_workflows
    config_accessor :participants_modal do
      true
    end

    def self.find_parser_class(manifest)
      "Decidim::DirectVerifications::Parsers::#{manifest.to_s.camelize}".safe_constantize || Decidim::DirectVerifications::Parsers::NameParser
    end
  end
end
