# frozen_string_literal: true

module LsLVM
  module Interface
    class Resource < BaseResource

      attr_reader :raw

      def initialize(raw, **kwargs)
        @raw = raw
        super(**kwargs)
      end
      delegate_missing_to :raw
    end
  end
end
