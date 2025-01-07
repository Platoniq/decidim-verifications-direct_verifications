# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe UserStats do
      subject { described_class.new(organization) }

      let(:confirmed) { create(:user, :confirmed, organization:) }
      let(:other_confirmed) { create(:user, :confirmed, organization:) }
      let(:another_confirmed) { create(:user, :confirmed, organization:) }
      let(:unconfirmed) { create(:user, organization:) }
      let(:other_unconfirmed) { create(:user, organization:) }
      let(:organization) do
        create(:organization, available_authorizations: %w(direct_verifications other_verification))
      end
      let(:direct_verification) do
        create(:authorization, :granted, user: confirmed, name: "direct_verifications", organization:)
      end
      let(:other_direct_verification) do
        create(:authorization, :granted, user: unconfirmed, name: "direct_verifications", organization:)
      end
      let(:other_verification) do
        create(:authorization, :granted, user: confirmed, name: "other_verification", organization:)
      end

      context "when no one registered" do
        it "has empty totals" do
          expect(subject.registered).to eq(0)
          expect(subject.unconfirmed).to eq(0)
          expect(subject.authorized).to eq(0)
          expect(subject.authorized_unconfirmed).to eq(0)
        end
      end

      context "when counting users for all methods" do
        before do
          confirmed
          other_confirmed
          another_confirmed
          unconfirmed
          other_unconfirmed
          direct_verification
          other_direct_verification
          other_verification
        end

        it "has registered only" do
          expect(subject.registered).to eq(5)
          expect(subject.unconfirmed).to eq(2)
          expect(subject.authorized).to eq(3)
          expect(subject.authorized_unconfirmed).to eq(1)
        end
      end

      context "when counting users for one method" do
        before do
          confirmed
          other_confirmed
          another_confirmed
          unconfirmed
          other_unconfirmed
          direct_verification
          other_direct_verification
          other_verification
          subject.authorization_handler = "direct_verifications"
        end

        it "has registered only" do
          expect(subject.registered).to eq(2)
          expect(subject.unconfirmed).to eq(1)
          expect(subject.authorized).to eq(2)
          expect(subject.authorized_unconfirmed).to eq(1)
        end
      end
    end
  end
end
