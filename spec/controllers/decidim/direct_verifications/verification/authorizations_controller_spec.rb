# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Verification
  describe AuthorizationsController do
    routes { Decidim::DirectVerifications::Verification::Engine.routes }

    let(:organization) do
      create(:organization, available_authorizations: [verification_type])
    end
    let(:verification_type) { "direct_verifications" }
    let(:user) { create(:user, :confirmed) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET new" do
      context "when the handler is not valid" do
        it "redirects the user" do
          get :new, params: { handler: "foo" }
          expect(response).to redirect_to("/authorizations")
        end
      end

      context "when the handler is valid" do
        it "redirects the user" do
          get :new, params: { handler: "direct_verifications" }
          expect(response).to redirect_to("/authorizations")
        end
      end
    end
  end
end
