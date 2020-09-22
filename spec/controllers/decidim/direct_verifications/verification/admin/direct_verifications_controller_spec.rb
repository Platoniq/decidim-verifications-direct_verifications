# frozen_string_literal: true

require "spec_helper"
require "decidim/direct_verifications/tests/verification_controller_examples"

module Decidim::DirectVerifications::Verification::Admin
  describe DirectVerificationsController, type: :controller do
    routes { Decidim::DirectVerifications::Verification::AdminEngine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) do
      create(:organization, available_authorizations: [verification_type])
    end
    let(:verification_type) { "direct_verifications" }
    let(:authorized_user) { create(:user, email: "authorized@example.com", organization: organization) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET index" do
      context "when the handler is valid" do
        it "renders the index template" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template("decidim/direct_verifications/verification/admin/direct_verifications/index")
        end
      end
    end

    describe "POST create" do
      context "when parameters are defaults" do
        params = { userlist: "" }
        it_behaves_like "checking users", params
        it "have no registered or authorized users" do
          post :create, params: params
          expect(flash[:info]).to include("0 are registered")
          expect(flash[:info]).to include("0 authorized")
          expect(flash[:info]).to include("unconfirmed")
          expect(flash[:info]).to include("detected")
        end
      end

      context "when register users with check" do
        params = { userlist: "mail@example.com", register: true }
        it_behaves_like "checking users", params
        it_behaves_like "registering users", params
        it "renders the index with warning message" do
          post :create, params: params
          expect(subject).to render_template("decidim/direct_verifications/verification/admin/direct_verifications/index")
        end
      end

      context "when register users with authorize" do
        params = { userlist: "mail@example.com", register: true, authorize: "in" }

        it_behaves_like "registering users", params
        it_behaves_like "authorizing users", params

        it "redirects with notice and warning messages" do
          post :create, params: params
          expect(subject).to redirect_to(action: :index)
        end

        context "when in metadata mode" do
          around do |example|
            original_processor = Rails.configuration.direct_verifications_processor
            Rails.configuration.direct_verifications_processor = :metadata
            example.run
            Rails.configuration.direct_verifications_processor = original_processor
          end

          it "stores any extra columns as authorization metadata" do
            post :create, params: {
              userlist: "username,mail@example.com,consumer",
              register: true,
              authorize: "in"
            }

            user = Decidim::User.find_by(email: "mail@example.com")
            authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
            expect(authorization.metadata).to eq("name" => "username", "type" => "consumer")
          end
        end
      end

      context "when register users with revoke" do
        params = { userlist: "authorized@example.com", authorize: "out" }
        it_behaves_like "revoking users", params
      end
    end
  end
end
