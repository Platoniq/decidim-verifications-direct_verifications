# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class Parser
        EMAIL_REGEXP = /([A-Z0-9+._-]+@[A-Z0-9._-]+\.[A-Z0-9_-]+)\b/i.freeze

        def initialize(txt, mode: Rails.configuration.direct_verifications_processor)
          @txt = txt
          @emails = {}
          @entry_parser = (mode == :metadata ? MetadataEntryParser.new : NameEntryParser.new)
        end

        def to_h
          lines.each do |line|
            EMAIL_REGEXP.match(line) do |match|
              email = match[0]
              emails[email] = entry_parser.parse_data(email, line)
            end
          end

          emails
        end

        private

        attr_reader :txt, :emails, :entry_parser

        def lines
          entry_parser.lines(txt)
        end
      end
    end
  end
end
