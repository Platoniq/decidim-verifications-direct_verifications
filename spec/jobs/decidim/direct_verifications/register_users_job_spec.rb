# frozen_string_literal: true

require "spec_helper"
require "tempfile"

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
          .with(current_user, kind_of(Instrumenter), :registered)
          .and_return(mailer)
      end

      it "creates the user" do
        Tempfile.create("import.csv") do |file|
          file.write(userslist)
          file.rewind

          expect { described_class.perform_later(file.path, organization, current_user) }
            .to change(Decidim::User, :count).from(1).to(2)

          user = Decidim::User.find_by(email: "brandy@example.com")
          expect(user.name).to eq("brandy")
        end
      end

      it "does not authorize the user" do
        Tempfile.create("import.csv") do |file|
          file.write(userslist)
          file.rewind

          described_class.perform_later(file.path, organization, current_user)

          user = Decidim::User.find_by(email: "brandy@example.com")
          authorization = Decidim::Authorization.find_by(decidim_user_id: user.id)
          expect(authorization).to be_nil
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
