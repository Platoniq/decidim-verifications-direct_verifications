# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    module Verification
      describe CreateImport do
        subject(:command) { described_class.new(form) }

        let(:form) do
          instance_double(CreateImportForm, file: file, organization: organization, user: user, action: action)
        end
        let(:filename) { file_fixture("users.csv") }
        let(:file) { Rack::Test::UploadedFile.new(filename, "text/csv") }
        let(:organization) { build(:organization) }
        let(:user) { build(:user) }
        let(:action) { :register }

        before do
          allow(RegisterUsersJob).to receive(:perform_later)
          allow(RevokeUsersJob).to receive(:perform_later)
        end

        context "when the form is valid" do
          before do
            allow(form).to receive(:valid?).and_return(true)
          end

          context "when the action is register" do
            let(:action) { :register }

            it "calls the RegisterUsersJob job" do
              command.call
              expect(RegisterUsersJob).to have_received(:perform_later)
            end

            it "does not call the RevokeUsersJob job" do
              command.call
              expect(RevokeUsersJob).not_to have_received(:perform_later)
            end

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end
          end

          context "when the action is revoke" do
            let(:action) { :revoke }

            it "does not call the RegisterUsersJob job" do
              command.call
              expect(RegisterUsersJob).not_to have_received(:perform_later)
            end

            it "calls the RevokeUsersJob job" do
              command.call
              expect(RevokeUsersJob).to have_received(:perform_later)
            end

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end
          end
        end

        context "when the form is not valid" do
          before do
            allow(form).to receive(:valid?).and_return(false)
          end

          it "does not call the RegisterUsersJob job" do
            command.call
            expect(RegisterUsersJob).not_to have_received(:perform_later)
          end

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
