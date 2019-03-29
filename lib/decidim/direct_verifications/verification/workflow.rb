# frozen_string_literal: true

require "decidim/verifications"

Decidim::Verifications.register_workflow(:direct_verifications) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
  workflow.admin_engine = Decidim::DirectVerifications::Verification::AdminEngine
end
