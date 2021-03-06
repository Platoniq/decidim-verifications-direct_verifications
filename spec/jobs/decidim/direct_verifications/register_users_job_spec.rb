# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe RegisterUsersJob, type: :job do
      let(:userslist) { "Name,Email,Type\r\n\"\",brandy@example.com,consumer" }
      let(:organization) { create(:organization) }
      let!(:current_user) { create(:user, organization: organization) }
      let(:mailer) { double(:mailer, deliver_now: true) }

      around do |example|
        perform_enqueued_jobs { example.run }
      end

      before do
        allow(ImportMailer)
          .to receive(:finished_processing)
          .with(current_user, kind_of(Instrumenter), :registered, "direct_verifications")
          .and_return(mailer)
      end

      it "creates the user" do
        expect { described_class.perform_later(userslist, organization, current_user, "direct_verifications") }
          .to change(Decidim::User, :count).from(1).to(2)

        user = Decidim::User.find_by(email: "brandy@example.com")
        expect(user.name).to eq("brandy")
      end

      it "does not authorize the user" do
        described_class.perform_later(userslist, organization, current_user, "direct_verifications")

        user = Decidim::User.find_by(email: "brandy@example.com")
        authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
        expect(authorization).to be_nil
      end

      it "notifies the result by email" do
        described_class.perform_later(userslist, organization, current_user, "direct_verifications")
        expect(mailer).to have_received(:deliver_now)
      end
    end
  end
end
