# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module DirectVerifications
    module Admin
      module NeedsVerificationSnippets
        extend ActiveSupport::Concern

        included do
          helper_method :snippets
        end

        def snippets
          return @snippets if @snippets

          @snippets = Decidim::Snippets.new

          @snippets.add(:direct_verifications, ActionController::Base.helpers.javascript_pack_tag("decidim_direct_verifications_participants"))
          @snippets.add(:head, @snippets.for(:direct_verifications))

          @snippets
        end
      end
    end
  end
end
