# frozen_string_literal: true
require 'decidim/verifications'

Decidim::Verifications.register_workflow(:batch_users_authorization_handler) do |workflow|
  # workflow.engine = Decidim::Verifications::BatchUsers::Engine
  workflow.admin_engine = Decidim::Verifications::BatchUsers::AdminEngine
end
