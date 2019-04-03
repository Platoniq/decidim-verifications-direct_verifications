# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe UserProcessor do
      subject { described_class.new(organization, user) }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) do
        create(:organization, available_authorizations: ["direct_verifications"])
      end

      context "when emails are passed" do
        it "has hash with automatic names" do
          subject.send(:emails=, "em@il.com" => "")
          expect(subject.emails).to eq("em@il.com" => "em")
        end
        it "has hash with passed names" do
          subject.send(:emails=, "em@il.com" => "", "em@il.net" => "A name")
          expect(subject.emails).to eq("em@il.com" => "em", "em@il.net" => "A name")
        end
      end

      context "when emails are not passed" do
        it "has empty hash" do
          subject.send(:emails=, {})
          expect(subject.emails).to eq({})
        end
      end

      context "when add processed" do
        it "has unique emails per type" do
          subject.send(:add_processed, :registered, "em@il.com")
          subject.send(:add_processed, :registered, "em@il.com")
          expect(subject.processed[:registered].count).to eq(1)
          subject.send(:add_processed, :authorized, "em@il.com")
          subject.send(:add_processed, :authorized, "em@il.com")
          expect(subject.processed[:authorized].count).to eq(1)
        end
      end

      context "when add errors" do
        it "has unique emails per type" do
          subject.send(:add_error, :registered, "em@il.com")
          subject.send(:add_error, :registered, "em@il.com")
          expect(subject.errors[:registered].count).to eq(1)
          subject.send(:add_error, :authorized, "em@il.com")
          subject.send(:add_error, :authorized, "em@il.com")
          expect(subject.errors[:authorized].count).to eq(1)
        end
      end

      context "when registers a valid users" do
        before do
          subject.emails = ["em@il.com", "em@il.com", "em@il.net"]
          subject.register_users
        end

        it "has no errors" do
          expect(subject.processed[:registered].count).to eq(2)
          expect(subject.errors[:registered].count).to eq(0)
          expect(subject.total(:unconfirmed)).to eq(2)
        end
        it "totals returns 0 if invalid type is given" do
          expect(subject.total(:test)).to eq(0)
        end
        it "totals returns registered users" do
          expect(subject.total(:registered)).to eq(2)
        end
      end

      context "when registers invalid users" do
        before do
          subject.emails = ["em@il.org", ""]
          subject.register_users
        end

        it "has errors" do
          expect(subject.processed[:registered].count).to eq(1)
          expect(subject.errors[:registered].count).to eq(1)
        end
        it "totals returns registered users" do
          expect(subject.total(:registered)).to eq(1)
        end
      end

      context "when authorize confirmed users" do
        before do
          subject.emails = { user.email => user.name }
          # subject.register_users
          subject.authorize_users
        end

        it "has no errors" do
          expect(subject.processed[:authorized].count).to eq(1)
          expect(subject.errors[:authorized].count).to eq(0)
        end
        it "totals returns authorized users" do
          expect(subject.total(:authorized)).to eq(1)
        end
      end

      context "when authorize unconfirmed users" do
        before do
          subject.emails = ["em@mail.com"]
          subject.register_users
          subject.authorize_users
        end

        it "has no errors" do
          expect(subject.processed[:authorized].count).to eq(1)
          expect(subject.errors[:authorized].count).to eq(0)
        end
        it "totals returns authorized users" do
          expect(subject.total(:authorized)).to eq(1)
          expect(subject.total(:unconfirmed)).to eq(1)
        end
      end

      context "when authorize unregistered users" do
        before do
          subject.emails = ["em@mail.com"]
          subject.authorize_users
        end

        it "has errors" do
          expect(subject.processed[:authorized].count).to eq(0)
          expect(subject.errors[:authorized].count).to eq(1)
        end
        it "totals returns 0 users" do
          expect(subject.total(:authorized)).to eq(0)
          expect(subject.total(:unconfirmed)).to eq(0)
          expect(subject.total(:registered)).to eq(0)
        end
      end

      context "when revoke existing users" do
        before do
          subject.emails = { user.email => user.name }
          subject.authorize_users
          subject.revoke_users
        end

        it "has no errors" do
          expect(subject.processed[:revoked].count).to eq(1)
          expect(subject.errors[:revoked].count).to eq(0)
        end
        it "totals returns 0 authorized users" do
          expect(subject.total(:authorized)).to eq(0)
        end
      end

      context "when revoke non-existing users" do
        before do
          subject.emails = ["em@il.com"]
          subject.authorize_users
          subject.revoke_users
        end

        it "has no errors" do
          expect(subject.processed[:revoked].count).to eq(0)
          expect(subject.errors[:revoked].count).to eq(1)
        end
        it "totals returns 0 authorized users" do
          expect(subject.total(:authorized)).to eq(0)
        end
      end
    end
  end
end
