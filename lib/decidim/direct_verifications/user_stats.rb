# frozen_string_literal: true

module Decidim
  module DirectVerifications
    class UserStats
      def initialize(organization)
        @organization = organization
        @authorization_handler = ""
        @emails = []
      end

      attr_reader :organization, :authorization_handler
      attr_accessor :emails

      def authorization_handler=(name)
        @workflow_manifest = nil
        @authorization_handler = name
      end

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
        authorized_users(false)
      end

      def authorized_users(strict = true)
        q = Decidim::Authorization.joins(:user)
        unless authorization_handler.empty?
          q = q.where(name: authorization_handler)
          if strict
            q = q.where.not(granted_at: nil)
            q = q.where("decidim_authorizations.granted_at >= :date", date: Time.current - expires_in) if expires_in
          end
        end
        q = q.where("decidim_users.decidim_organization_id=:org and decidim_users.email!=''", org: organization.id)
        return q if emails.empty?
        q.where("decidim_users.email IN (:emails)", emails: emails)
      end

      def expires_in
        return unless workflow_manifest
        return if workflow_manifest.expires_in.zero?
        workflow_manifest.expires_in
      end

      def workflow_manifest
        return if authorization_handler.empty?
        @workflow_manifest ||= Decidim::Verifications.find_workflow_manifest(authorization_handler)
      end
    end
  end
end
