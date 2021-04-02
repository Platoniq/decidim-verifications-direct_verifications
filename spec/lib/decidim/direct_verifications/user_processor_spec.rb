# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe UserProcessor do
      subject { described_class.new(organization, user, session, instrumenter) }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:session) { double(:session) }
      let(:organization) do
        create(:organization, available_authorizations: ["direct_verifications"])
      end
      let(:instrumenter) { Instrumenter.new(nil) }

      context "when emails are passed" do
        it "uses the specified name" do
          subject.emails = { "em@il.com" => "em", "em@il.net" => "A name" }
          expect(subject.emails).to eq("em@il.com" => "em", "em@il.net" => "A name")
        end

        it "passes all the extra data when specified" do
          subject.emails = { "em@il.com" => { name: "A name", type: "consumer" } }
          expect(subject.emails).to eq("em@il.com" => { name: "A name", type: "consumer" })
        end
      end

      context "when emails are not passed" do
        it "uses an empty hash" do
          subject.emails = {}
          expect(subject.emails).to eq({})
        end
      end

      describe "#register_users" do
        context "when registering valid users" do
          before do
            subject.emails = ["em@il.com", "em@il.com", "em@il.net"]
            subject.register_users
          end

          it "has no errors" do
            expect(instrumenter.processed[:registered].count).to eq(2)
            expect(instrumenter.errors[:registered].count).to eq(0)
          end
        end

        context "when registering valid users with metadata" do
          before do
            subject.emails = { "em@il.com" => { name: "Brandy", type: "producer" } }
            subject.register_users
          end

          it "has no errors" do
            expect(instrumenter.processed[:registered].count).to eq(1)
            expect(instrumenter.errors[:registered].count).to eq(0)
          end
        end
      end

      describe "#authorize_users" do
        context "when authorizing confirmed users" do
          before do
            subject.emails = { user.email => user.name }
          end

          it "has no errors" do
            subject.authorize_users

            expect(instrumenter.processed[:authorized].count).to eq(1)
            expect(instrumenter.errors[:authorized].count).to eq(0)
          end
        end

        context "when authorizing confirmed users with metadata" do
          before do
            subject.emails = { user.email => { name: user.name, type: "consumer" } }
          end

          it "stores user data as authorization metadata" do
            subject.authorize_users
            expect(Authorization.last.metadata).to eq("name" => user.name, "type" => "consumer")
          end
        end

        context "when authorizing unconfirmed users" do
          before do
            subject.emails = ["em@mail.com"]
            subject.register_users
          end

          it "has no errors" do
            subject.authorize_users

            expect(instrumenter.processed[:authorized].count).to eq(1)
            expect(instrumenter.errors[:authorized].count).to eq(0)
          end
        end

        context "when authorizing unconfirmed users with metadata" do
          before do
            subject.emails = { "em@mail.com" => { type: "consumer" } }
            subject.register_users
          end

          it "stores user data as authorization metadata" do
            subject.authorize_users

            expect(Decidim::User.find_by(email: "em@mail.com").name).to eq("em")
            expect(Authorization.last.metadata).to eq("type" => "consumer")
          end
        end
      end

      context "when revoking existing users" do
        before do
          subject.emails = { user.email => user.name }
          subject.authorize_users
        end

        it "has no errors" do
          subject.revoke_users

          expect(instrumenter.processed[:revoked].count).to eq(1)
          expect(instrumenter.errors[:revoked].count).to eq(0)
        end
      end

      context "when revoking non-existing users" do
        before do
          subject.emails = ["em@il.com"]
          subject.authorize_users
        end

        it "has errors" do
          subject.revoke_users

          expect(instrumenter.processed[:revoked].count).to eq(0)
          expect(instrumenter.errors[:revoked].count).to eq(1)
        end
      end
    end
  end
end
