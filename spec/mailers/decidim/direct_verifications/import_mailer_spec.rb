# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe ImportMailer, type: :mailer do
      describe "#successful_import" do
        subject(:mail) { described_class.successful_import(user) }

        let(:user) { build(:user) }

        it "sends the email to the passed user" do
          expect(mail.to).to eq([user.email])
        end

        it "localizes the subject" do
          user.locale = "ca"
          user.save!
          expect(I18n).to receive(:with_locale).with("ca")

          mail.body
        end

        it "renders the body" do
          expect(mail.body.encoded).to include("Register successful")
        end
      end
    end
  end
end
