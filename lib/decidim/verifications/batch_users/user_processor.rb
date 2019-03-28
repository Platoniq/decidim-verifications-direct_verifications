# frozen_string_literal: true

module Decidim
  module Verifications
    module BatchUsers
      class UserProcessor
        def initialize(text)
          @emails = extract_emails_to_hash text
        end

        def user_hash
          @emails || {}
        end

        # TODO: dirty text test:
        # test1@test.com
        # test2@test.com
        # use test3@t.com
        # User <a@b.co> another@email.com third@email.com@as.com
        # Test 1 test1@test.com
        def extract_emails_to_hash(txt)
          reg = /([^@\r\n]*)\b([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})\b/i
          txt.scan(reg).map {|m| [m[1], m[0].delete('<>').strip]}.to_h
        end
      end
    end
  end
end