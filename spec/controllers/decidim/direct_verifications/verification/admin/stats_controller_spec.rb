# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Verification::Admin
  describe StatsController, type: :controller do
    routes { Decidim::DirectVerifications::Verification::AdminEngine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) do
      create(:organization, available_authorizations: [verification_type])
    end
    let(:verification_type) { "direct_verifications" }
    let(:authorized_user) { create(:user, email: "authorized@example.com", organization: organization) }
    # let(:authorization) do
    #   create(
    #     :authorization,
    #     :granted,
    #     name: verification_type,
    #     user: authorized_user
    #   )
    # end

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET index" do
      context "when the handler is valid" do
        it "renders the index template" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template("decidim/direct_verifications/verification/admin/stats/index")
        end
      end
    end

  end
end
