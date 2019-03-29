# frozen_string_literal: true

require "decidim/verifications"

Decidim::Verifications.register_workflow(:direct_verifications) do |workflow|
  workflow.admin_engine = Decidim::DirectVerifications::Verification::AdminEngine
end
