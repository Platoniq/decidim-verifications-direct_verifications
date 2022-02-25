# frozen_string_literal: true

require "spec_helper"

module Decidim::DirectVerifications::Parsers
  describe MetadataParser do
    subject { described_class.new(txt) }

    describe "#header" do
      context "when the first line has empty columns" do
        let(:txt) { "Melina.morrison@bccm.coop,MORRISON Melina,,,11" }

        it "raises an error" do
          expect { subject.to_h }.to raise_error(Decidim::DirectVerifications::InputParserError)
        end
      end
    end

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

      context "when the text has empty columns" do
        let(:txt) do
          <<-EMAILS.strip_heredoc
            Name,Email,Department,Salary
            Bob,bob@example.com,,1000
          EMAILS
        end

        it "skips those columns" do
          expect(subject.to_h).to eq(
            "bob@example.com" => { "department" => nil, "name" => "Bob", "salary" => "1000" }
          )
        end
      end

      context "when the text is a CSV with headers" do
        let(:txt) do
          <<-ROWS.strip_heredoc
            Name,Email,Department,Salary
            Bob,bob@email.com,Engineering,1000
            Jane,jane@email.com,Sales,2000
            John,john@email.com,Management,5000
          ROWS
        end

        it "returns the data in a hash with the email as key" do
          expect(subject.to_h).to eq(
            "bob@email.com" => { "name" => "Bob", "department" => "Engineering", "salary" => "1000" },
            "jane@email.com" => { "name" => "Jane", "department" => "Sales", "salary" => "2000" },
            "john@email.com" => { "name" => "John", "department" => "Management", "salary" => "5000" }
          )
        end

        context "and the CSV includes quotes" do
          let(:txt) do
            <<-CSV.strip_heredoc
            Name,Email,Type
            use,test3@t.com,type
            User,<a@b.co> another@email.com,third@email.com@as.com
            Test 1, test1@test.com, customer
            \"Test\\| 4\", <test4@test.com, producer
            CSV
          end

          it "returns the data in a hash with the email as key" do
            expect(subject.to_h).to eq(
              "test3@t.com" => { "name" => "use", "type" => "type" },
              "a@b.co" => { "name" => "User", "type" => "third@email.com@as.com" },
              "test1@test.com" => { "name" => "Test 1", "type" => "customer" },
              "test4@test.com" => { "name" => "Test\\| 4", "type" => "producer" }
            )
          end
        end

        context "and the CSV includes trailing or leading whitespaces" do
          let(:txt) do
            <<-CSV.strip_heredoc
            Name, Email, Type
            Ava Hawkins, ava@example.com, collaborator
            CSV
          end

          it "returns the data in a hash with the email as key" do
            expect(subject.to_h).to eq(
              "ava@example.com" => { "name" => "Ava Hawkins", "type" => "collaborator" }
            )
          end
        end

        context "when the name is not specified" do
          let(:txt) do
            <<-EMAILS.strip_heredoc
              email
              em@il.com
            EMAILS
          end

          it "infers the name from the email" do
            expect(subject.to_h).to eq("em@il.com" => {})
          end
        end

        context "when entries are duplicate" do
          let(:txt) do
            <<-EMAILS.strip_heredoc
              name,email
              brandy,brandy@example.com
              brandy,brandy@example.com
            EMAILS
          end

          it "keeps only one" do
            expect(subject.to_h).to eq("brandy@example.com" => { "name" => "brandy" })
          end
        end
      end
    end
  end
end
