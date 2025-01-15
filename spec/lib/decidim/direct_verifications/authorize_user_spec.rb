# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe AuthorizeUser do
      subject do
        described_class.new(email, data, session, organization, instrumenter, authorization_handler)
      end

      let(:authorization_handler) { :direct_verifications }

      describe "#call" do
        let(:data) { user.name }

        context "when authorizing confirmed users" do
          let(:organization) { build(:organization) }
          let(:user) { create(:user, organization:) }
          let(:email) { user.email }
          let(:session) { {} }
          let(:instrumenter) { instance_double(Instrumenter, add_processed: true, add_error: true) }

          context "when passing the user name" do
            let(:data) { user.name }

            it "tracks the operation" do
              subject.call

              expect(instrumenter).to have_received(:add_processed).with(:authorized, email)
              expect(instrumenter).not_to have_received(:add_error)
            end

            it "authorizes the user" do
              expect(Verification::ConfirmUserAuthorization).to receive(:call)
              subject.call
            end
          end

          context "when passing user data" do
            let(:data) { { name: user.name, type: "consumer" } }

            it "stores it as authorization metadata" do
              subject.call
              expect(Authorization.last.metadata).to eq("name" => user.name, "type" => "consumer")
            end

            it "authorizes the user" do
              expect(Verification::ConfirmUserAuthorization).to receive(:call)
              subject.call
            end
          end

          context "when the authorization already exists" do
            context "when the authorization is not granted" do
              let!(:authorization) { create(:authorization, :pending, user:, name: :direct_verifications) }

              it "authorizes the user" do
                expect(Verification::ConfirmUserAuthorization).to receive(:call)
                subject.call
              end
            end

            context "when the authorization is already granted and expired" do
              let!(:authorization) { create(:authorization, :granted, user:, name: :direct_verifications) }

              before do
                allow(authorization).to receive(:expired?).and_return(true)
                allow(Decidim::Authorization).to receive(:find_or_initialize_by).and_return(authorization)
              end

              it "does not authorize the user" do
                expect(Verification::ConfirmUserAuthorization).to receive(:call)
                subject.call
              end
            end

            context "when the authorization is already granted and not expired" do
              let!(:authorization) { create(:authorization, :granted, user:, name: :direct_verifications) }

              before do
                allow(authorization).to receive(:expired?).and_return(false)
                allow(Decidim::Authorization).to receive(:find_or_initialize_by).and_return(authorization)
              end

              it "does not authorize the user" do
                expect(Verification::ConfirmUserAuthorization).not_to receive(:call)
                subject.call
              end
            end
          end

          context "when the user fails to be authorized" do
            let(:form) { instance_double(Verification::DirectVerificationsForm, valid?: false) }
            let(:data) { user.name }

            before do
              allow(Verification::DirectVerificationsForm)
                .to receive(:new).with(email: user.email, name: user.name) { form }
            end

            it "tracks the error" do
              subject.call
              expect(instrumenter).to have_received(:add_error).with(:authorized, email)
            end
          end
        end

        context "when authorizing unregistered users" do
          let(:organization) { build(:organization) }
          let(:user) { nil }
          let(:email) { "em@mail.com" }
          let(:data) { "Andy" }
          let(:session) { {} }
          let(:instrumenter) { instance_double(Instrumenter, add_processed: true, add_error: true) }

          it "tracks an error" do
            subject.call

            expect(instrumenter).not_to have_received(:add_processed)
            expect(instrumenter).to have_received(:add_error).with(:authorized, email)
          end

          it "does not authorize the user" do
            expect(Verification::ConfirmUserAuthorization).not_to receive(:call)
            subject.call
          end
        end
      end
    end
  end
end
