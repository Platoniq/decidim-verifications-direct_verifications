# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user
          return permission_action unless user.admin?

          toggle_allow(Decidim::DirectVerifications.manage_workflows.map(&:to_s).include?(context.fetch(:name).to_s)) if permission_action.subject == :direct_authorization

          permission_action
        end
      end
    end
  end
end
