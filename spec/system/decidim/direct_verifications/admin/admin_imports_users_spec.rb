# frozen_string_literal: true

require "spec_helper"

describe "Admin imports users", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:i18n_scope) { "decidim.direct_verifications.verification.admin" }
  let(:filename) { file_fixture("users.csv") }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim_admin_direct_verifications.new_import_path
  end

  context "when registering users" do
    it "registers users through a CSV file" do
      attach_file("CSV file with users data", filename)

      check(I18n.t("#{i18n_scope}.new.register"))

      perform_enqueued_jobs do
        click_button("Upload file")
      end

      expect(page).to have_admin_callout(I18n.t("#{i18n_scope}.imports.create.success"))
      expect(page).to have_current_path(decidim_admin_direct_verifications.new_import_path)

      expect(ActionMailer::Base.deliveries.first.to).to contain_exactly("brandy@example.com")
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Invitation instructions")

      expect(ActionMailer::Base.deliveries.last.body.encoded).to include(
        I18n.t("#{i18n_scope}.imports.mailer.registered", count: 1, successful: 1, errors: 0)
      )
    end
  end

  context "when registering and authorizing users" do
    it "registers and authorizes users through a CSV file" do
      attach_file("CSV file with users data", filename)

      check(I18n.t("#{i18n_scope}.new.register"))
      choose(I18n.t("#{i18n_scope}.new.authorize"))

      perform_enqueued_jobs do
        click_button("Upload file")
      end

      expect(page).to have_admin_callout(I18n.t("#{i18n_scope}.imports.create.success"))
      expect(page).to have_current_path(decidim_admin_direct_verifications.new_import_path)

      user = Decidim::User.last
      expect(Decidim::Authorization.find_by(decidim_user_id: user.id)).not_to be_nil

      expect(ActionMailer::Base.deliveries.first.to).to contain_exactly("brandy@example.com")
      expect(ActionMailer::Base.deliveries.first.subject).to eq("Invitation instructions")

      expect(ActionMailer::Base.deliveries.last.body.encoded).to include(
        I18n.t(
          "#{i18n_scope}.imports.mailer.authorized",
          handler: :direct_verifications,
          count: 1,
          successful: 1,
          errors: 0
        )
      )
    end
  end

  context "when revoking users" do
    let(:user_to_revoke) do
      create(:user, name: "Brandy", email: "brandy@example.com", organization: organization)
    end

    before do
      create(:authorization, :granted, user: user_to_revoke, name: :direct_verifications)
    end

    it "revokes users through a CSV file" do
      attach_file("CSV file with users data", filename)

      choose(I18n.t("#{i18n_scope}.new.revoke"))

      perform_enqueued_jobs do
        click_button("Upload file")
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path(decidim_admin_direct_verifications.new_import_path)

      expect(Decidim::Authorization.find_by(decidim_user_id: user_to_revoke.id)).to be_nil

      expect(ActionMailer::Base.deliveries.last.body.encoded).to include(
        I18n.t(
          "#{i18n_scope}.imports.mailer.revoked",
          handler: :direct_verifications,
          count: 1,
          successful: 1,
          errors: 0
        )
      )
    end
  end
end
