# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe RevokeUsersJob, type: :job do
      let(:userslist) { "Name,Email,Type\r\n\"\",brandy@example.com,consumer" }
      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, organization: organization) }
      let(:mailer) { double(:mailer, deliver_now: true) }

      let(:user) { create(:user, organization: organization, email: "brandy@example.com") }
      let!(:authorization) { create(:authorization, :granted, user: user, name: :direct_verifications) }

      around do |example|
        perform_enqueued_jobs { example.run }
      end

      before do
        allow(ImportMailer)
          .to receive(:finished_processing)
          .with(current_user, kind_of(Instrumenter), :revoked)
          .and_return(mailer)
      end

      it "deletes the user authorization" do
        Tempfile.create("import.csv") do |file|
          file.write(userslist)
          file.rewind

          described_class.perform_later(file.path, organization, current_user)
          expect(Decidim::Authorization.find_by(id: authorization.id)).to be_nil
        end
      end

      it "notifies the result by email" do
        Tempfile.create("import.csv") do |file|
          file.write(userslist)
          file.rewind

          described_class.perform_later(file.path, organization, current_user)
          expect(mailer).to have_received(:deliver_now)
        end
      end
    end
  end
end
