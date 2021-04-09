# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    module Verification
      describe CreateImportForm do
        subject(:form) { described_class.from_params(attributes) }

        let(:attributes) do
          {
            user: build(:user),
            organization: build(:organization),
            file: double(File),
            authorize: action
          }
        end
        let(:action) { "in" }

        context "when all attributes are provided" do
          it { is_expected.to be_valid }
        end

        context "when action is in" do
          let(:action) { "in" }

          it "returns it as :register" do
            expect(form.action).to eq(:register)
          end
        end

        context "when action is out" do
          let(:action) { "out" }

          it "returns it as :revoke" do
            expect(form.action).to eq(:revoke)
          end
        end

        context "when action is check" do
          let(:action) { "check" }

          it "returns it as :check" do
            expect(form.action).to eq(:check)
          end
        end

        context "when action is unknown" do
          let(:action) { "dummy" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
