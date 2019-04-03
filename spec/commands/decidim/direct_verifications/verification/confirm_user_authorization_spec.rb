# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    module Verification
      module Admin
        describe ConfirmUserAuthorization do
          subject { described_class.new(authorization, form) }

          let(:organization) do
            create(:organization, available_authorizations: ["direct_verifications"])
          end

          let(:authorization) do
            create(
              :authorization,
              :pending,
              name: "direct_verifications"
            )
          end

          let(:form) do
            DirectVerificationsForm.new(name: name, email: email)
          end

          let(:user) { authorization.user }
          let(:name) { 'Bob' }
          let(:email) { 'm@rley.com' }

          context "when form data is valid" do
            it "broadcasts ok" do
              expect { subject.call }.to broadcast(:ok)
            end
          end

          context "when form data is invalid" do
            let(:email) { '' }
            it "broadcasts invalid" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end

        end
      end
    end
  end
end
