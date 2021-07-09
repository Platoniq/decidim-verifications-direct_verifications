# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.modify do
  factory :authorization do
    trait :direct_verification do
      name { "direct_verifications" }
    end
  end
end
