# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Verification::Admin
  describe AuthorizationsController, type: :controller do
    routes { Decidim::DirectVerifications::Verification::AdminEngine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization: organization) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "#index" do
      it "renders the decidim/admin/users layout" do
        get :index
        expect(response).to render_template("layouts/decidim/admin/users")
      end
    end
  end
end
