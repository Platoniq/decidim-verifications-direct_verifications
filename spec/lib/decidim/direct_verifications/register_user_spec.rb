# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe RegisterUser do
      subject { described_class.new(email, name, organization, user, instrumenter) }

      let(:user) { build(:user) }
      let(:organization) { build(:organization) }
      let(:instrumenter) do
        instance_double(UserProcessor, add_processed: true, add_error: true, log_action: true)
      end

      let(:email) { "em@il.com" }
      let(:name) { "Joni" }

      describe "#call" do
        context "when registering valid users" do
          let(:email) { "em@il.com" }
          let(:name) { "Joni" }

          it "tracks the operation" do
            subject.call

            expect(instrumenter).to have_received(:add_processed).with(:registered, email)
            expect(instrumenter).to have_received(:log_action).with(kind_of(Decidim::User))
            expect(instrumenter).not_to have_received(:add_error)
          end

          it "invites the user" do
            expect(InviteUser).to receive(:call)
            subject.call
          end
        end

        context "when registering users that already exist" do
          let(:email) { "em@il.com" }
          let(:name) { "Joni" }

          let!(:user) { create(:user, email: email, organization: organization) }

          it "doesn't track the operation" do
            subject.call

            expect(instrumenter).not_to have_received(:add_processed)
            expect(instrumenter).not_to have_received(:add_error)
          end

          it "does not invite the user" do
            expect(InviteUser).not_to receive(:call)
            subject.call
          end
        end

        context "when registering users without name" do
          let(:email) { "em@il.com" }
          let(:name) { nil }

          it "tracks the operation" do
            subject.call

            expect(instrumenter).to have_received(:add_processed)
            expect(instrumenter).not_to have_received(:add_error)
          end

          it "infers the name from the email" do
            subject.call
            expect(Decidim::User.last.name).to eq("em")
          end

          it "invites the user" do
            expect(InviteUser).to receive(:call)
            subject.call
          end
        end

        context "when registering invalid users" do
          let(:email) { "" }
          let(:name) { "" }

          it "tracks the operation" do
            expect { subject.call }.to raise_error(ActiveRecord::NotNullViolation)
            expect(instrumenter).to have_received(:add_error).with(:registered, email)
          end

          it "tries to invite the user" do
            expect(InviteUser).to receive(:call)
            subject.call
          end
        end
      end
    end
  end
end
