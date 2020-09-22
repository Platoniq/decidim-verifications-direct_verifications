# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class Parser
        LINE_DELIMITER = /[\r\n;,]/.freeze
        EMAIL_REGEXP = /([A-Z0-9+._-]+@[A-Z0-9._-]+\.[A-Z0-9_-]+)\b/i.freeze
        NON_ALPHA_CHARS = /[^[:print:]]|[\"\$\<\>\|\\]/.freeze

        def initialize(txt)
          @txt = txt
          @emails = {}
        end

        def to_h
          reading_lines do |line|
            EMAIL_REGEXP.match(line) do |match|
              email = match[0]
              name = name_from(line, email)

              emails[email] = strip_non_alpha_chars(name)
            end
          end

          emails
        end

        private

        attr_reader :txt, :emails

        def reading_lines
          txt.split(LINE_DELIMITER).each do |line|
            yield(line)
          end
        end

        def name_from(line, email)
          line.split(email).first
        end

        def strip_non_alpha_chars(str)
          (str.presence || "").gsub(NON_ALPHA_CHARS, "").strip
        end
      end
    end
  end
end
