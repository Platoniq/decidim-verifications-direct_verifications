# frozen_string_literal: true

FactoryBot.define do
  factory :user_processor, class: "Decidim::DirectVerifications::UserProcessor" do
    user
    organization
  end
end
