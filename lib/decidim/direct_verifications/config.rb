# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class << self
      attr_accessor :config
      def configure
        yield self.config ||= Config.new
      end
    end

    class Config
      attr_reader :manage_workflows
      def manage_workflows=(manage_workflows)
        @manage_workflows.concat(manage_workflows).uniq!
      end

      def initialize
        @manage_workflows = ["direct_verifications"]
      end
    end
  end
end
