# frozen_string_literal: true

require "spec_helper"

describe "Admin manages imported authorizations", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:authorization) { create(:authorization, :direct_verification) }
  let!(:non_direct_authorization) { create(:authorization) }

  let(:scope) { "decidim.direct_verifications.verification.admin" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "lists authorizations imported through direct_verifications" do
    visit decidim_admin_direct_verifications.direct_verifications_path
    click_link I18n.t("index.authorizations", scope: scope)

    expect(page).to have_current_path(decidim_admin_direct_verifications.authorizations_path)

    within "table thead" do
      expect(page).to have_content(I18n.t("authorizations.index.name", scope: scope).upcase)
      expect(page).to have_content(I18n.t("authorizations.index.metadata", scope: scope).upcase)
      expect(page).to have_content(I18n.t("authorizations.index.user_name", scope: scope).upcase)
      expect(page).to have_content(I18n.t("authorizations.index.created_at", scope: scope).upcase)
    end

    within "tr[data-authorization-id=\"#{authorization.id}\"]" do
      expect(page).to have_content(authorization.name)
      expect(page).to have_content(authorization.metadata)
      expect(page).to have_content(authorization.decidim_user_id)
      expect(page).to have_content(authorization.created_at)
    end

    expect(page).not_to have_content(non_direct_authorization.name)
  end
end
