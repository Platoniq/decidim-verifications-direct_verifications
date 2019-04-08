# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe Config do
      subject { described_class.new }

      let(:methods) { %w(method1 method2 method1) }

      context "when workflows are not specified" do
        it "has one verification method" do
          expect(subject.manage_workflows).to eq(["direct_verifications"])
        end
      end

      context "when workflows are specified" do
        before do
          subject.manage_workflows = methods
        end

        it "has a valid array of uniq values" do
          expect(subject.manage_workflows).to eq(%w(direct_verifications method1 method2))
        end
      end
    end
  end
end
