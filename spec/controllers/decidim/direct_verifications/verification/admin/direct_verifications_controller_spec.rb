# frozen_string_literal: true

require "spec_helper"

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
      shared_examples_for "checking users" do |params|
        context "when check without mails" do
          it "renders the index with info message" do
            params[:userlist] = ""
            post :create, params: params
            expect(flash[:info]).not_to be_empty
            expect(flash[:info]).to include("0 users detected")
            expect(subject).to render_template("decidim/direct_verifications/verification/admin/direct_verifications/index")
          end
        end

        context "when check with mails" do
          it "renders the index with info message" do
            params[:userlist] = "mail@example.com"
            post :create, params: params
            expect(flash[:info]).not_to be_empty
            expect(flash[:info]).to include("1 users detected")
            expect(subject).to render_template("decidim/direct_verifications/verification/admin/direct_verifications/index")
          end
        end
      end

      shared_examples_for "registering users" do |params|
        context "when send valid emails" do
          it "creates warning message" do
            post :create, params: params
            expect(flash[:warning]).not_to be_empty
            expect(flash[:warning]).to include("1 detected")
            expect(flash[:warning]).to include("0 errors")
            expect(flash[:warning]).to include("1 users")
            expect(flash[:warning]).to include("registered")
          end
        end
      end

      shared_examples_for "authorizing users" do |params|
        context "when send valid emails" do
          it "creates notice message" do
            post :create, params: params
            expect(flash[:notice]).not_to be_empty
            expect(flash[:notice]).to include("1 detected")
            expect(flash[:notice]).to include("0 errors")
            expect(flash[:notice]).to include("1 users")
            expect(flash[:notice]).to include("verified")
          end
        end
      end

      shared_examples_for "revoking users" do |params|
        context "when send valid emails" do
          it "creates notice message" do
            create(
              :authorization,
              :granted,
              name: verification_type,
              user: authorized_user
            )
            post :create, params: params
            expect(flash[:notice]).not_to be_empty
            expect(flash[:notice]).to include("1 detected")
            expect(flash[:notice]).to include("0 errors")
            expect(flash[:notice]).to include("1 users")
            expect(flash[:notice]).to include("revoked")
          end
        end
      end

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
      end

      context "when register users with revoke" do
        params = { userlist: "authorized@example.com", authorize: "out" }
        it_behaves_like "revoking users", params
      end
    end

    describe "email extractor" do
      it "converts empty text to empty hash" do
        txt = ""
        h = controller.send(:extract_emails_to_hash, txt)
        expect(h).to eq({})
      end
      it "converts invalid text to empty hash" do
        txt = "nonsense emails...\nnot_an@email\nno em@il"
        h = controller.send(:extract_emails_to_hash, txt)
        expect(h).to eq({})
      end
      it "converts valid text to emails hash" do
        txt = "test1@test.com\ntest2@test.com\nuse test3@t.com\nUser <a@b.co> another@email.com third@email.com@as.com\nTest 1 test1@test.com\n\"Test\\| 4\" <test4@test.com"
        h = controller.send(:extract_emails_to_hash, txt)
        expect(h).to eq(
          "a@b.co" => "User",
          "another@email.com" => "",
          "test1@test.com" => "Test 1",
          "test2@test.com" => "",
          "test3@t.com" => "use",
          "test4@test.com" => "Test 4",
          "third@email.com" => ""
        )
      end
    end
  end
end
