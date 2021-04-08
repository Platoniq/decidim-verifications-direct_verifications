# frozen_string_literal: true

require "spec_helper"

describe "Admin imports users", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim_admin_direct_verifications.new_import_path
  end

  context "when visiting the imports page" do
    let(:filename) { "fixture.csv" }
    let!(:fixture_file) do
      CSV.open(filename, "wb") do |csv|
        csv << %w(Name Email Type)
        csv << %w(Brandy brandy@example.com consumer)
      end
    end

    after { File.delete(filename) }

    it "enables uploading a CSV file" do
      attach_file("CSV file with users data", filename)

      perform_enqueued_jobs do
        click_button("Upload file")
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path(decidim_admin_direct_verifications.new_import_path)
      expect(Decidim::User.last.email).to eq("brandy@example.com")
      expect(ActionMailer::Base.deliveries.last.subject)
        .to eq(I18n.t("decidim.direct_verifications.verification.admin.imports.successful_import.subject"))
    end
  end
end
