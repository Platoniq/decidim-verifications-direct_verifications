# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      class NameEntryParser
        NON_ALPHA_CHARS = /[^[:print:]]|[\"\$\<\>\|\\]/.freeze

        def parse_data(_email, name, _line)
          strip_non_alpha_chars(name)
        end

        private

        def strip_non_alpha_chars(str)
          (str.presence || "").gsub(NON_ALPHA_CHARS, "").strip
        end
      end
    end
  end
end
