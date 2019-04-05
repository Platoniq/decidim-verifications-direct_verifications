# frozen_string_literal: true

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        class StatsController < Decidim::Admin::ApplicationController
          include NeedsPermission

          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
            stats = UserStats.new(current_organization)
            @stats = {
              t(".global") => stats_hash(stats)
            }
            current_organization.available_authorizations.map do |a|
              stats.authorization_handler = a
              @stats[t("#{a}.name", scope: "decidim.authorization_handlers")] = stats_hash(stats)
            end
          end

          private

          def stats_hash(stats)
            {
              registered: stats.registered,
              authorized: stats.authorized,
              unconfirmed: stats.unconfirmed,
              authorized_unconfirmed: stats.authorized_unconfirmed
            }
          end
        end
      end
    end
  end
end
