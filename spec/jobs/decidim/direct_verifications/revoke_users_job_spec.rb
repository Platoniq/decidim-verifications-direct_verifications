# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe RevokeUsersJob, type: :job do
      let(:filename) { file_fixture("users.csv").realpath.to_s }
      let(:file) { Rack::Test::UploadedFile.new(filename, "text/csv") }
      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, organization: organization) }
      let(:mailer) { double(:mailer, deliver_now: true) }

      let(:user) { create(:user, organization: organization, email: "brandy@example.com") }
      let!(:authorization) { create(:authorization, :granted, user: user, name: :direct_verifications) }

      around do |example|
        perform_enqueued_jobs { example.run }
      end

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(CsvUploader).to receive(:store_dir).and_return("")
        # rubocop:enable RSpec/AnyInstance

        allow(ImportMailer)
          .to receive(:finished_processing)
          .with(current_user, kind_of(Instrumenter), :revoked, "direct_verifications")
          .and_return(mailer)
      end

      it "deletes the user authorization" do
        described_class.perform_later(file.path, organization, current_user, "direct_verifications")
        expect(Decidim::Authorization.find_by(id: authorization.id)).to be_nil
      end

      it "notifies the result by email" do
        described_class.perform_later(file.path, organization, current_user, "direct_verifications")
        expect(mailer).to have_received(:deliver_now)
      end
    end
  end
end
