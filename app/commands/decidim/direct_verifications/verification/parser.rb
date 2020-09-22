# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class Parser
        LINE_DELIMITER = /[\r\n;,]/.freeze
        EMAIL_REGEXP = /([A-Z0-9+._-]+@[A-Z0-9._-]+\.[A-Z0-9_-]+)\b/i.freeze

        def initialize(txt, mode: Rails.configuration.direct_verifications_processor)
          @txt = txt
          @emails = {}
          @entry_parser = (mode == :metadata ? MetadataEntryParser.new : NameEntryParser.new)
        end

        def to_h
          reading_lines do |line|
            EMAIL_REGEXP.match(line) do |match|
              email = match[0]
              name = parse_name(line, email)

              emails[email] = entry_parser.parse_data(email, name, line)
            end
          end

          emails
        end

        private

        attr_reader :txt, :emails, :entry_parser

        def reading_lines
          txt.split(LINE_DELIMITER).each do |line|
            yield(line)
          end
        end

        def parse_name(line, email)
          line.split(email).first
        end
      end
    end
  end
end
