# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class Stats
      attr_reader :count, :successful, :errors

      def self.from(instrumenter, type)
        new(
          count: instrumenter.emails_count(type),
          successful: instrumenter.processed_count(type),
          errors: instrumenter.errors_count(type)
        )
      end

      def initialize(count:, successful:, errors:)
        @count = count
        @successful = successful
        @errors = errors
      end
    end
  end
end
