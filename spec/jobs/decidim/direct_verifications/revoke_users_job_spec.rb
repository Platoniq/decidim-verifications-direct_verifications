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
      let(:blob) { ActiveStorage::Blob.create_and_upload!(io: file, filename: file.original_filename) }

      around do |example|
        perform_enqueued_jobs { example.run }
      end

      before do
        allow(ImportMailer)
          .to receive(:finished_processing)
          .with(current_user, kind_of(Instrumenter), :revoked, "direct_verifications")
          .and_return(mailer)
      end

      it "deletes the user authorization" do
        described_class.perform_later(blob.id, organization, current_user, "direct_verifications")
        expect(Decidim::Authorization.find_by(id: authorization.id)).to be_nil
      end

      it "notifies the result by email" do
        described_class.perform_later(blob.id, organization, current_user, "direct_verifications")
        expect(mailer).to have_received(:deliver_now)
        expect { blob.download }.not_to raise_error(ActiveStorage::FileNotFoundError)
      end

      it "removes file" do
        described_class.perform_later(blob.id, organization, current_user, "direct_verifications", remove_file: true)
        expect { blob.download }.to raise_error(ActiveStorage::FileNotFoundError)
      end
    end
  end
end
