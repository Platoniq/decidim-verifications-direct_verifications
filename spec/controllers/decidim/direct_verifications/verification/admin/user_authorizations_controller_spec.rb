# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Verification::Admin
  describe UserAuthorizationsController, type: :controller do
    routes { Decidim::DirectVerifications::Verification::AdminEngine.routes }

    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let(:organization) do
      create(:organization, available_authorizations: %w(direct_verifications another_verification))
    end
    let(:verification_type) { "direct_verifications" }
    let!(:authorized_user) { create(:user, email: "authorized@example.com", organization: organization) }
    let!(:authorization) { create :authorization, :granted, name: verification_type, user: authorized_user }
    let!(:unauthorized_user) { create(:user, email: "unauthorized@example.com", organization: organization) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "GET show" do
      it "renders the ajax show template" do
        get :show, params: { id: authorized_user.id }
        expect(response).to have_http_status(:ok)
        expect(subject).to render_template("decidim/direct_verifications/verification/admin/user_authorizations/show")
      end
    end

    describe "GET update" do
      it "creates an authorization" do
        get :update, params: { id: authorized_user.id, name: verification_type }
        expect(flash[:notice]).to be_present
        expect(response).to have_http_status(:redirect)
      end

      # when auth is not handled by direct verification, permission deny
      context "when authorization is not handled by direct_verifications" do
        let(:verification_type) { "another_verification" }

        it "cannot create an authorization" do
          get :update, params: { id: unauthorized_user.id, name: verification_type }
          expect(flash[:alert]).to be_present
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    describe "GET destroy" do
      it "destroys an authorization" do
        get :destroy, params: { id: authorized_user.id, name: verification_type }
        expect(flash[:notice]).to be_present
        expect(response).to have_http_status(:redirect)
      end

      context "when authorization is not handled by direct_verifications" do
        let(:verification_type) { "another_verification" }

        it "cannot create an authorization" do
          get :destroy, params: { id: unauthorized_user.id, name: verification_type }
          expect(flash[:alert]).to be_present
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
