# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Verification::Admin
  describe ImportsController, type: :controller do
    routes { Decidim::DirectVerifications::Verification::AdminEngine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization: organization) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "#new" do
      it "authorizes the action" do
        expect(controller).to receive(:allowed_to?).with(:create, :authorization, {})
        get :new
      end
    end

    describe "#create" do
      let(:filename) { "fixture.csv" }
      let(:file) { Rack::Test::UploadedFile.new(filename, "text/csv") }

      before do
        CSV.open(filename, "wb") do |csv|
          csv << %w(Name Email Type)
          csv << %w(Brandy brandy@example.com consumer)
        end
      end

      it "authorizes the action" do
        expect(controller).to receive(:allowed_to?).with(:create, :authorization, {})
        post :create, params: { file: file }
      end
    end
  end
end
