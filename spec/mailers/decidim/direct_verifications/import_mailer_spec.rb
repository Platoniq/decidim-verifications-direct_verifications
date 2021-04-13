# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe ImportMailer, type: :mailer do
      let(:user) { build(:user) }

      describe "#successful_import" do
        subject(:mail) { described_class.successful_import(user) }

        it "sends the email to the passed user" do
          expect(mail.to).to eq([user.email])
        end

        it "localizes the subject" do
          user.locale = "ca"
          expect(I18n).to receive(:with_locale).with("ca")

          mail.body
        end

        it "renders the body" do
          expect(mail.body.encoded).to include("Register successful")
        end

        it "sets the organization" do
          expect(mail.body.encoded).to include(user.organization.name)
        end
      end
    end
  end
end
