# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe RevokeUser do
      subject { described_class.new(email, organization, instrumenter, "direct_verifications") }

      let(:user) { create(:user, organization: organization) }
      let(:email) { user.email }

      describe "#call" do
        let(:organization) { build(:organization) }
        let(:instrumenter) { instance_double(Instrumenter, add_processed: true, add_error: true) }

        context "when revoking existing users" do
          let(:email) { user.email }

          before { create(:authorization, :granted, user: user, name: :direct_verifications) }

          it "tracks the operation" do
            subject.call
            expect(instrumenter).to have_received(:add_processed).with(:revoked, email)
          end

          it "revokes the user authorization" do
            expect(Verification::DestroyUserAuthorization).to receive(:call)
            subject.call
          end
        end

        context "when revoking non-existing users" do
          let(:email) { "em@mail.com" }

          it "tracks the error" do
            subject.call
            expect(instrumenter).to have_received(:add_error).with(:revoked, email)
          end

          it "does not revoke the authorization" do
            expect(Verification::DestroyUserAuthorization).not_to receive(:call)
            subject.call
          end
        end

        context "when the authorization does not exist" do
          it "does not track the operation" do
            subject.call
            expect(instrumenter).not_to have_received(:add_processed)
            expect(instrumenter).not_to have_received(:add_error)
          end

          it "does not revoke the authorization" do
            expect(Verification::DestroyUserAuthorization).not_to receive(:call)
            subject.call
          end
        end

        context "when the authorization is not granted" do
          before { create(:authorization, :pending, user: user, name: :direct_verifications) }

          it "does not track the operation" do
            subject.call
            expect(instrumenter).not_to have_received(:add_processed)
            expect(instrumenter).not_to have_received(:add_error)
          end

          it "does not revoke the authorization" do
            expect(Verification::DestroyUserAuthorization).not_to receive(:call)
            subject.call
          end
        end

        context "when the authorization fails to be destroyed" do
          let(:user) { create(:user, organization: organization) }
          let(:email) { user.email }
          let(:authorization) { create(:authorization, :granted, user: user, name: :direct_verifications) }

          before do
            allow(authorization).to receive(:destroy!).and_raise(ActiveRecord::ActiveRecordError)
            allow(Authorization)
              .to receive(:find_by)
              .with(user: user, name: "direct_verifications")
              .and_return(authorization)
          end

          it "lets lower-level exceptions pass through" do
            expect { subject.call }.to raise_error(ActiveRecord::ActiveRecordError)
          end
        end

        context "when passing a non-default authorization handler" do
          subject { described_class.new(email, organization, instrumenter, authorization_handler) }

          let(:authorization_handler) { :other_verification_method }
          let(:user) { create(:user, organization: organization) }

          before { create(:authorization, :granted, user: user, name: authorization_handler) }

          it "tracks the operation" do
            subject.call
            expect(instrumenter).to have_received(:add_processed).with(:revoked, email)
          end

          it "revokes the user authorization" do
            expect(Verification::DestroyUserAuthorization).to receive(:call)
            subject.call
          end
        end
      end
    end
  end
end
