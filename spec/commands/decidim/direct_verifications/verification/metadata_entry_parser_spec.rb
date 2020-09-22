# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Verification
  describe Parser do
    subject { described_class.new(txt, mode: :metadata) }

    describe "#to_h" do
      context "when the text is empty" do
        let(:txt) { "" }

        it "returns an empty hash" do
          expect(subject.to_h).to eq({})
        end
      end

      context "when the text is invalid" do
        let(:txt) do
          <<-EMAILS.strip_heredoc
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
          <<-EMAILS.strip_heredoc
            use,test3@t.com,type
            User,"<a@b.co>\ranother@email.com",third@email.com@as.com
            "Test 1",test1@test.com,customer
            "\"Test\\| 4\"",<test4@test.com,producer
            "dot.email@test.com\rMy.Dot:Name",with.dot@email.dot.com,type
          EMAILS
        end

        it "returns the emails in a hash" do
          expect(subject.to_h).to eq(
            "test3@t.com" => { name: "use", type: "type" },
            "a@b.co" => { name: "User", type: "third@email.com@as.com" },
            "test1@test.com" => { name: "\"Test 1\"", type: "customer" },
            "test4@test.com" => { name: "\"\"Test\\| 4\"\"", type: "producer" },
            "dot.email@test.com" => { name: "\"dot.email@test.com\rMy.Dot:Name\"", type: "type" }
          )
        end
      end
    end
  end
end
