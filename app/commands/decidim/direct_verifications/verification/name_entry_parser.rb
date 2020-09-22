# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class NameEntryParser
        LINE_DELIMITER = /[\r\n;,]/.freeze
        NON_ALPHA_CHARS = /[^[:print:]]|[\"\$\<\>\|\\]/.freeze

        def lines(txt)
          txt.split(LINE_DELIMITER)
        end

        def parse_data(email, line)
          name = parse_name(email, line)
          strip_non_alpha_chars(name)
        end

        private

        def strip_non_alpha_chars(str)
          (str.presence || "").gsub(NON_ALPHA_CHARS, "").strip
        end

        def parse_name(email, line)
          line.split(email).first
        end
      end
    end
  end
end
