# frozen_string_literal: true

require_relative "direct_verifications/version"
require_relative "direct_verifications/user_processor"
require_relative "direct_verifications/user_stats"
require_relative "direct_verifications/verification"
require_relative "direct_verifications/parsers"

module Decidim
  module DirectVerifications
    class InputParserError < StandardError; end

    class << self
      def config = self

      def configure
        yield self
      end
    end

    # Specify in this variable which authorization methods can be managed by the plugin
    # Be careful to specify only what you really need
    mattr_accessor :manage_workflows, default: ["direct_verifications"]

    # The processor for the user uploaded data where to extract emails and other info
    # be default it uses Decidim::DirectVerifications::Parsers::NameParser
    # Currently available are:
    # - :name_parser
    # - :metadata_parser
    # A custom parser can be specified as long it respects the module hierachy
    mattr_accessor :input_parser, default: :name_parser

    # add a button to the participants list to be able to handle verifications from there
    # Manageable Verifications need to be registered in :manage_workflows
    mattr_accessor :participants_modal, default: true

    def self.find_parser_class(manifest)
      "Decidim::DirectVerifications::Parsers::#{manifest.to_s.camelize}".safe_constantize || Decidim::DirectVerifications::Parsers::NameParser
    end
  end
end
