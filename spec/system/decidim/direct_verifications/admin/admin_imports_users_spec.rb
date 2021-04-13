# frozen_string_literal: true

require "spec_helper"

describe "Admin imports users", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:i18n_scope) { "decidim.direct_verifications.verification.admin" }
  let(:last_email_delivery) { ActionMailer::Base.deliveries.last }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim_admin_direct_verifications.new_import_path
  end

  context "when visiting the imports page" do
    let(:filename) { file_fixture("users.csv") }

    context "when authorizing users" do
      it "registers users through a CSV file" do
        attach_file("CSV file with users data", filename)
        choose(I18n.t("#{i18n_scope}.new.authorize"))

        perform_enqueued_jobs do
          click_button("Upload file")
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_current_path(decidim_admin_direct_verifications.new_import_path)
        expect(Decidim::User.last.email).to eq("brandy@example.com")

        expect(last_email_delivery.subject).to eq(I18n.t("#{i18n_scope}.imports.mailer.subject"))
        expect(last_email_delivery.body.encoded).to include(
          I18n.t("#{i18n_scope}.direct_verifications.create.registered", count: 1, registered: 1, errors: 0)
        )
      end
    end
  end
end
