# frozen_string_literal: true

shared_examples_for "checking users" do |params|
  context "when check without mails" do
    it "renders the index with info message" do
      params[:userslist] = ""
      perform_enqueued_jobs do
        post :create, params: params
        expect(flash[:info]).not_to be_empty
        expect(flash[:info]).to include("0 users detected")
        expect(subject).to render_template("decidim/direct_verifications/verification/admin/direct_verifications/index")
      end
    end
  end

  context "when check with mails" do
    it "renders the index with info message" do
      params[:userslist] = "mail@example.com"
      perform_enqueued_jobs do
        post :create, params: params
        expect(flash[:info]).not_to be_empty
        expect(flash[:info]).to include("1 users detected")
        expect(subject).to render_template("decidim/direct_verifications/verification/admin/direct_verifications/index")
      end
    end
  end
end

shared_examples_for "registering users" do |params|
  context "when there are valid emails" do
    it "creates warning message" do
      perform_enqueued_jobs do
        post :create, params: params
        expect(flash[:warning]).not_to be_empty
        expect(flash[:warning]).to include("1 detected")
        expect(flash[:warning]).to include("0 errors")
        expect(flash[:warning]).to include("1 users")
        expect(flash[:warning]).to include("registered")
      end
    end
  end
end

shared_examples_for "authorizing users" do |params|
  context "when there are valid emails" do
    it "creates notice message" do
      perform_enqueued_jobs do
        post :create, params: params
        expect(flash[:notice]).not_to be_empty
        expect(flash[:notice]).to include("1 detected")
        expect(flash[:notice]).to include("0 errors")
        expect(flash[:notice]).to include("1 users")
        expect(flash[:notice]).to include("verified")
      end
    end
  end
end

shared_examples_for "revoking users" do |params|
  context "when there are valid emails" do
    it "creates notice message" do
      create(
        :authorization,
        :granted,
        name: verification_type,
        user: authorized_user
      )
      perform_enqueued_jobs do
        post :create, params: params
        expect(flash[:notice]).not_to be_empty
        expect(flash[:notice]).to include("1 detected")
        expect(flash[:notice]).to include("0 errors")
        expect(flash[:notice]).to include("1 users")
        expect(flash[:notice]).to include("revoked")
      end
    end
  end
end
