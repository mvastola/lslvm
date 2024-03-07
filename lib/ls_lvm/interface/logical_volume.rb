# frozen_string_literal: true

module LsLVM
  module Interface
    class LogicalVolume < Resource
      attr_reader :volume_group
      alias_method :vg, :volume_group

      delegate *%i[], to: :vg, prefix: true
      delegate *%i[segments], to: :raw, prefix: true

      delegate *%i[segments], to: :vg
      alias_method :segs, :segments

      def initialize(*args, volume_group:, **kwargs)
        @volume_group = volume_group
        super(*args, **kwargs)
      end

      def size = ByteSize.bytes(raw.size)

      memoize def lv_segments
        raw_segments.sort_by(&:start_le).map do |raw|
          LogicalVolumeSegment.new(raw, logical_volume: self, volume_group:, interface:)
        end
      end
      alias_method :lv_segs, :lv_segments

      def name = super.sub(/\A\[(.*)\]\z/, '\1')
      def display_name
        binding.pry if raw.name.blank?

        raw.name
      end

      def pretty_print_instance_variables
        super.without(*%i[volume_group lv_segments])
      end
    end
  end
end
