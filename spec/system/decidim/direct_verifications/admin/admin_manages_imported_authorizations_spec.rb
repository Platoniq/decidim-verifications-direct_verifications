# frozen_string_literal: true

require "spec_helper"

describe "Admin manages imported authorizations" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:out_of_scope_user) { create(:user, :confirmed) }

  let!(:authorization) { create(:authorization, :direct_verification, user:) }
  let!(:out_of_scope_authorization) { create(:authorization, :direct_verification, user: out_of_scope_user) }
  let!(:non_direct_authorization) { create(:authorization) }

  let(:scope) { "decidim.direct_verifications.verification.admin" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim_admin_direct_verifications.direct_verifications_path
    click_on I18n.t("index.authorizations", scope:)
  end

  context "when listing authorizations" do
    it "lists authorizations imported through direct_verifications" do
      within "table thead" do
        expect(page).to have_content(I18n.t("authorizations.index.name", scope:))
        expect(page).to have_content(I18n.t("authorizations.index.metadata", scope:))
        expect(page).to have_content(I18n.t("authorizations.index.user_name", scope:))
        expect(page).to have_content(I18n.t("authorizations.index.created_at", scope:))
      end

      within "tr[data-authorization-id=\"#{authorization.id}\"]" do
        expect(page).to have_content(authorization.name)
        expect(page).to have_content(authorization.metadata)
        expect(page).to have_content(authorization.user.name)
        expect(page).to have_content(authorization.created_at)
      end

      expect(page).to have_no_content(non_direct_authorization.name)
      expect(page).to have_no_content(out_of_scope_authorization.user.name)
    end

    it "lets users navigate to stats and new import" do
      expect(page).to have_link(t("decidim.direct_verifications.verification.admin.index.stats"))
      expect(page).to have_link(t("decidim.direct_verifications.verification.admin.authorizations.index.new_import"))
    end
  end

  context "when destroying an authorization" do
    it "destroys the authorizations" do
      within "tr[data-authorization-id=\"#{authorization.id}\"]" do
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_no_content("tr[data-authorization-id=\"#{authorization.id}\"]")
      expect(page).to have_admin_callout("successfully")
    end
  end
end
