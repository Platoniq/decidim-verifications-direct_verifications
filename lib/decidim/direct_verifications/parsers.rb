# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Parsers
      autoload :BaseParser, "decidim/direct_verifications/parsers/base_parser"
      autoload :NameParser, "decidim/direct_verifications/parsers/name_parser"
      autoload :MetadataParser, "decidim/direct_verifications/parsers/metadata_parser"
    end
  end
end
