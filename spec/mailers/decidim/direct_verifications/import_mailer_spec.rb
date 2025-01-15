# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe ImportMailer do
      let(:user) { build(:user) }

      describe "#finished_processing" do
        subject(:mail) { described_class.finished_processing(user, instrumenter, type, handler) }

        let(:instrumenter) { instance_double(Instrumenter, emails_count: 1, processed_count: 1, errors_count: 0) }
        let(:type) { :registered }
        let(:handler) { :direct_verifications }

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

        it "sets the organization" do
          expect(mail.body.encoded).to include(user.organization.name)
        end

        context "when the type is :registered" do
          let(:type) { :registered }

          context "when the import had no errors" do
            it "shows the number of errors" do
              expect(mail.body.encoded).to include(
                "1 participants have been successfully registered (1 detected, 0 errors)"
              )
            end
          end

          context "when the import had errors" do
            let(:instrumenter) { instance_double(Instrumenter, emails_count: 1, processed_count: 0, errors_count: 1) }

            it "shows the number of errors" do
              expect(mail.body.encoded).to include(
                "0 participants have been successfully registered (1 detected, 1 errors)"
              )
            end
          end
        end

        context "when the type is :revoked" do
          let(:type) { :revoked }

          context "when the import had no errors" do
            it "shows the number of errors" do
              expect(mail.body.encoded).to include(
                "Verification from 1 participants have been revoked using [direct_verifications] (1 detected, 0 errors)"
              )
            end
          end

          context "when the import had errors" do
            let(:instrumenter) { instance_double(Instrumenter, emails_count: 1, processed_count: 0, errors_count: 1) }

            it "shows the number of errors" do
              expect(mail.body.encoded).to include(
                "Verification from 0 participants have been revoked using [direct_verifications] (1 detected, 1 errors)"
              )
            end
          end
        end
      end
    end
  end
end
