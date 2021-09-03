# frozen_string_literal: true

require "spec_helper"

describe "Admin creates direct verifications", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:i18n_scope) { "decidim.direct_verifications.verification.admin.direct_verifications" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim_admin_direct_verifications.direct_verifications_path
  end

  around do |example|
    original_processor = ::Decidim::DirectVerifications.input_parser
    ::Decidim::DirectVerifications.input_parser = :metadata_parser
    example.run
    ::Decidim::DirectVerifications.input_parser = original_processor
  end

  context "when registering users" do
    context "and no header is provided" do
      it "shows an error message" do
        fill_in "Emails list", with: "brandy@example.com,,consumer"
        check "register"
        choose "authorize_in"

        click_button "Send and process the list"

        expect(page).to have_content(I18n.t("#{i18n_scope}.create.missing_header"))
      end
    end
  end
end
