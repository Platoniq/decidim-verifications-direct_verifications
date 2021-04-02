# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DirectVerifications
    describe Instrumenter do
      subject { described_class.new(current_user) }

      let(:current_user) { build_stubbed(:user) }

      shared_examples "an error event" do |type|
        context "when the email does not exist" do
          it "adds the email" do
            subject.add_error(type, "email@example.com")
            expect(subject.errors[type]).to contain_exactly("email@example.com")
          end
        end

        context "when the email already exists" do
          before { subject.add_error(type, "email@example.com") }

          it "does not duplicate the email" do
            subject.add_error(type, "email@example.com")
            expect(subject.errors[type]).to contain_exactly("email@example.com")
          end
        end
      end

      shared_examples "a process event" do |type|
        context "when the email does not exist" do
          it "adds the email" do
            subject.add_processed(type, "email@example.com")
            expect(subject.processed[type]).to contain_exactly("email@example.com")
          end
        end

        context "when the email already exists" do
          before { subject.add_processed(type, "email@example.com") }

          it "does not duplicate the email" do
            subject.add_processed(type, "email@example.com")
            expect(subject.processed[type]).to contain_exactly("email@example.com")
          end
        end
      end

      describe "#add_error" do
        it_behaves_like "an error event", :registered
        it_behaves_like "an error event", :authorized
        it_behaves_like "an error event", :revoked

        context "when the provided type does not exist" do
          let(:type) { :fake }

          it "raises due to NilClass" do
            expect { subject.add_error(type, "email@example.com") }.to raise_error(NoMethodError)
          end
        end
      end

      describe "#add_processed" do
        it_behaves_like "an error event", :registered
        it_behaves_like "an error event", :authorized
        it_behaves_like "an error event", :revoked

        context "when the provided type does not exist" do
          let(:type) { :fake }

          it "raises due to NilClass" do
            expect { subject.add_processed(type, "email@example.com") }.to raise_error(NoMethodError)
          end
        end
      end

      describe "#track" do
        context "when a user is passed" do
          let(:user) { build_stubbed(:user) }

          before { allow(Decidim.traceability).to receive(:perform_action!) }

          context "and the provided type exists" do
            let(:type) { :registered }

            it "adds the process event" do
              subject.track(type, "email@example.com", user)
              expect(subject.processed[type]).to contain_exactly("email@example.com")
            end

            it "logs the action" do
              expect(Decidim.traceability).to receive(:perform_action!).with(
                "invite",
                user,
                current_user,
                extra: {
                  invited_user_role: "participant",
                  invited_user_id: user.id
                }
              )
              subject.track(type, "email@example.com", user)
            end
          end

          context "and the provided type does not exist" do
            let(:type) { :fake }

            it "raises due to NilClass" do
              expect { subject.track(type, "email@example.com", user) }.to raise_error(NoMethodError)
            end
          end
        end

        context "when a user is not passed" do
          context "and the provided type exists" do
            let(:type) { :registered }

            it "adds the error event" do
              subject.track(type, "email@example.com")
              expect(subject.errors[type]).to contain_exactly("email@example.com")
            end
          end

          context "and the provided type does not exist" do
            let(:type) { :fake }

            it "raises due to NilClass" do
              expect { subject.track(type, "email@example.com") }.to raise_error(NoMethodError)
            end
          end
        end
      end
    end
  end
end
