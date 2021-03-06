# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class Instrumenter
      def initialize(current_user)
        @current_user = current_user
        @errors = { registered: Set.new, authorized: Set.new, revoked: Set.new }
        @processed = { registered: Set.new, authorized: Set.new, revoked: Set.new }
      end

      def add_processed(type, email)
        @processed[type] << email
      end

      def add_error(type, email)
        @errors[type] << email
      end

      def processed_count(key)
        processed[key].size
      end

      def errors_count(key)
        errors[key].size
      end

      def emails_count(key)
        @processed[key].size + @errors[key].size
      end

      def track(event, email, user = nil)
        if user
          add_processed event, email
          log_action user
        else
          add_error event, email
        end
      end

      private

      attr_reader :current_user, :processed, :errors

      def log_action(user)
        Decidim.traceability.perform_action!(
          "invite",
          user,
          current_user,
          extra: {
            invited_user_role: "participant",
            invited_user_id: user.id
          }
        )
      end
    end
  end
end
