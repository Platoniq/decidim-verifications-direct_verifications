# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Verification::Admin
  describe ImportsController do
    routes { Decidim::DirectVerifications::Verification::AdminEngine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "#new" do
      it "authorizes the action" do
        expect(controller).to receive(:allowed_to?).with(:create, :authorization, {})
        get :new
      end

      it "renders the decidim/admin/users layout" do
        get :new
        expect(response).to render_template("layouts/decidim/admin/users")
      end
    end

    describe "#create" do
      let(:filename) { file_fixture("users.csv") }
      let(:file) { Rack::Test::UploadedFile.new(filename, "text/csv") }

      context "when the import is valid" do
        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:create, :authorization, {})
          post :create, params: { file: }
        end

        it "redirects to :new" do
          post :create, params: { file: }
          expect(response).to redirect_to(new_import_path)
        end
      end

      context "when the import is not valid" do
        it "authorizes the action" do
          expect(controller).to receive(:allowed_to?).with(:create, :authorization, {})
          post :create, params: {}
        end

        it "redirects to :new" do
          post :create, params: {}
          expect(response).to redirect_to(new_import_path)
        end

        it "displays an error" do
          post :create, params: {}
          expect(flash[:alert]).to eq(I18n.t("decidim.direct_verifications.verification.admin.imports.create.error"))
        end
      end
    end
  end
end
