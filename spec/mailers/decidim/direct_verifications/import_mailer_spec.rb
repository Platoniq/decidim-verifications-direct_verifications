# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe ImportMailer, type: :mailer do
      let(:user) { build(:user) }

      describe "#finished_registration" do
        subject(:mail) { described_class.finished_registration(user, instrumenter) }

        context "when the import had no errors" do
          let(:instrumenter) { instance_double(Instrumenter, emails_count: 1, processed_count: 1, errors_count: 0) }

          it "sends the email to the passed user" do
            expect(mail.to).to eq([user.email])
          end

          it "renders the subject" do
            expect(mail.subject).to eq(I18n.t("decidim.direct_verifications.verification.admin.imports.mailer.subject"))
          end

          it "localizes the subject" do
            user.locale = "ca"
            expect(I18n).to receive(:with_locale).with("ca")

            mail.body
          end

          it "renders the body" do
            expect(mail.body.encoded).to include(
              "1 users have been successfully registered (1 detected, 0 errors)"
            )
          end

          it "sets the organization" do
            expect(mail.body.encoded).to include(user.organization.name)
          end
        end

        context "when the import had errors" do
          let(:instrumenter) { instance_double(Instrumenter, emails_count: 1, processed_count: 0, errors_count: 1) }

          it "sends the email to the passed user" do
            expect(mail.to).to eq([user.email])
          end

          it "renders the subject" do
            expect(mail.subject).to eq(I18n.t("decidim.direct_verifications.verification.admin.imports.mailer.subject"))
          end

          it "localizes the subject" do
            user.locale = "ca"
            expect(I18n).to receive(:with_locale).with("ca")

            mail.body
          end

          it "renders the body" do
            expect(mail.body.encoded).to include(
              "0 users have been successfully registered (1 detected, 1 errors)"
            )
          end

          it "sets the organization" do
            expect(mail.body.encoded).to include(user.organization.name)
          end
        end
      end
    end
  end
end
