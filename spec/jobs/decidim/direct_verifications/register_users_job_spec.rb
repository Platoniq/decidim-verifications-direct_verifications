# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe RegisterUsersJob, type: :job do
      let(:filename) { file_fixture("users.csv").realpath.to_s }
      let(:file) { Rack::Test::UploadedFile.new(filename, "text/csv") }
      let(:organization) { create(:organization) }
      let!(:current_user) { create(:user, organization: organization) }
      let(:mailer) { double(:mailer, deliver_now: true) }
      let(:blob) { ActiveStorage::Blob.create_and_upload!(io: file, filename: file.original_filename) }

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
        expect { described_class.perform_later(blob.id, organization, current_user, "direct_verifications") }
          .to change(Decidim::User, :count).from(1).to(2)

        user = Decidim::User.find_by(email: "brandy@example.com")
        expect(user.name).to eq("brandy")
      end

      it "does not authorize the user" do
        described_class.perform_later(blob.id, organization, current_user, "direct_verifications")

        user = Decidim::User.find_by(email: "brandy@example.com")
        authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
        expect(authorization).to be_nil
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
