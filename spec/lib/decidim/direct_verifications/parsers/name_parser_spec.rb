# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Parsers
  describe NameParser do
    subject { described_class.new(txt) }

    describe "#to_h" do
      context "when the text is empty" do
        let(:txt) { "" }

        it "returns an empty hash" do
          expect(subject.to_h).to eq({})
        end
      end

      context "when the text is invalid" do
        let(:txt) do
          <<~EMAILS
            nonsense emails...
            not_an@email
            no em@il
          EMAILS
        end

        it "returns an empty hash" do
          expect(subject.to_h).to eq({})
        end
      end

      context "when the text is valid" do
        let(:txt) do
          <<~EMAILS
            test1@test.com
            test2@test.com
            use test3@t.com
            User <a@b.co>\ranother@email.com,third@email.com@as.com
            Test 1 test1@test.com
            "Test\\| 4" <test4@test.com
            dot.email@test.com\rMy.Dot:Name with.dot@email.dot.com;"My name" <my@email.net>, My other name <my-other@email.org>
          EMAILS
        end

        it "returns the emails in a hash" do
          expect(subject.to_h).to eq(
            "a@b.co" => "User",
            "another@email.com" => "another",
            "dot.email@test.com" => "dotemail",
            "my-other@email.org" => "My other name",
            "my@email.net" => "My name",
            "test1@test.com" => "Test 1",
            "test2@test.com" => "test2",
            "test3@t.com" => "use",
            "test4@test.com" => "Test 4",
            "third@email.com" => "third",
            "with.dot@email.dot.com" => "My.Dot:Name"
          )
        end
      end

      context "when the name is not specified" do
        let(:txt) do
          <<~EMAILS
            em+2@il.com
          EMAILS
        end

        it "infers the name from the email" do
          expect(subject.to_h).to eq("em+2@il.com" => "em2")
        end
      end

      context "when entries are duplicate" do
        let(:txt) do
          <<~EMAILS
            brandy,brandy@example.com
            brandy,brandy@example.com
          EMAILS
        end

        it "keeps only one" do
          expect(subject.to_h).to eq("brandy@example.com" => "brandy")
        end
      end
    end
  end
end
