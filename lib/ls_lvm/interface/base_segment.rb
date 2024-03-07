# frozen_string_literal: true

module LsLVM
  module Interface
    class BaseSegment < Resource
      attr_reader :volume_group

      alias_attribute :vg, :volume_group
      delegate *%i[], to: :vg, prefix: true

      def initialize(*args, volume_group:, **kwargs)
        @volume_group = volume_group
        super(*args, **kwargs)
      end

      def matches?(other = nil, **kwargs)
        return self == other if other.is_a?(self.class)
        return super(**kwargs) unless other.is_a?(BaseSegment) && !other.is_a?(self.class)

        raw.pe_ranges == other.pe_ranges
      end
    end
  end
end
