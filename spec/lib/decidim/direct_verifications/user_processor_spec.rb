# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe UserProcessor do
      subject { described_class.new(organization, user) }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) do
        create(:organization, available_authorizations: ["direct_verifications"])
      end

      context "when emails are passed" do
        it "has emails without names" do
          subject.send(:emails=, "em@il.com" => "")
          expect(subject.emails).to eq("em@il.com" => "em")
        end
        it "has emails with names" do
          subject.send(:emails=, "em@il.com" => "", "em@il.net" => "A name")
          expect(subject.emails).to eq("em@il.com" => "em", "em@il.net" => "A name")
        end
      end

      context "when emails are not passed" do
        it "has emails" do
          subject.send(:emails=, {})
          expect(subject.emails).to eq({})
        end
      end
    end
  end
end
