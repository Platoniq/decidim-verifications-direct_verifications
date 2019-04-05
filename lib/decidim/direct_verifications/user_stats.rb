# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class UserStats
      def initialize(organization)
        @organization = organization
        @authorization_handler = ""
        @emails = []
      end

      attr_accessor :organization, :authorization_handler, :emails

      def registered
        registered_users.count
      end

      def unconfirmed
        registered_users.where("decidim_users.confirmed_at IS NULL").count
      end

      def authorized
        authorized_users.count
      end

      def authorized_unconfirmed
        authorized_users.where("decidim_users.confirmed_at IS NULL").count
      end

      private

      def registered_users
        if authorization_handler.empty?
          filter = { decidim_organization_id: organization.id }
          filter[:email] = emails unless emails.empty?
          return User.where(filter)
        end
        authorized_users
      end

      def authorized_users
        q = Decidim::Authorization.joins(:user)
        q = q.where(name: authorization_handler) unless authorization_handler.empty?
        q = q.where("decidim_users.decidim_organization_id=:org", org: organization.id)
        return q if emails.empty?
        q.where("decidim_users.email IN (:emails)", emails: emails)
      end
    end
  end
end
