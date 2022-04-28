# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe OfficializationsController, type: :controller do
    routes { Decidim::Admin::Engine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) do
      create(:organization, available_authorizations: [verification_type])
    end
    let(:verification_type) { "direct_verifications" }
    let(:authorized_user) { create(:user, email: "authorized@example.com", organization: organization) }
    let(:snippets) { controller.helpers.snippets.display(:direct_verifications) }
    let(:modal_on) { true }

    before do
      allow(Decidim::DirectVerifications).to receive(:participants_modal).and_return(modal_on)
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET index" do
      it "renders the index page" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template("decidim/admin/officializations/index")
      end

      it "has snippets" do
        expect(snippets).to include("DirectVerificationsConfig")
      end

      context "when no modal" do
        let(:modal_on) { false }

        it "has no snippets" do
          expect(snippets).to be_nil
        end
      end
    end
  end
end
