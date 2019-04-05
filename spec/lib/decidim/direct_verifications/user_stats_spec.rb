# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe UserStats do
      subject { described_class.new(organization) }

      let(:confirmed) { create(:user, :confirmed, organization: organization) }
      let(:confirmed2) { create(:user, :confirmed, organization: organization) }
      let(:confirmed3) { create(:user, :confirmed, organization: organization) }
      let(:unconfirmed) { create(:user, organization: organization) }
      let(:unconfirmed2) { create(:user, organization: organization) }
      let(:organization) do
        create(:organization, available_authorizations: %w(direct_verifications other_verification))
      end
      let(:direct_verification) do
        create(:authorization, :granted, user: confirmed, name: "direct_verifications", organization: organization)
      end
      let(:direct_verification2) do
        create(:authorization, :granted, user: unconfirmed, name: "direct_verifications", organization: organization)
      end
      let(:other_verification) do
        create(:authorization, :granted, user: confirmed, name: "other_verification", organization: organization)
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
          confirmed2
          confirmed3
          unconfirmed
          unconfirmed2
          direct_verification
          direct_verification2
          other_verification
        end

        it "has registered only " do
          expect(subject.registered).to eq(5)
          expect(subject.unconfirmed).to eq(2)
          expect(subject.authorized).to eq(3)
          expect(subject.authorized_unconfirmed).to eq(1)
        end
      end

      context "when counting users for one method" do
        before do
          confirmed
          confirmed2
          confirmed3
          unconfirmed
          unconfirmed2
          direct_verification
          direct_verification2
          other_verification
          subject.authorization_handler = "direct_verifications"
        end

        it "has registered only " do
          expect(subject.registered).to eq(2)
          expect(subject.unconfirmed).to eq(1)
          expect(subject.authorized).to eq(2)
          expect(subject.authorized_unconfirmed).to eq(1)
        end
      end
    end
  end
end
