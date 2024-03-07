# frozen_string_literal: true

module LsLVM
  module Interface
    class PhysicalVolume < Resource
      attr_reader :volume_group
      alias_method :vg, :volume_group

      delegate *%i[], to: :volume_group, prefix: true
      delegate *%i[segments], to: :raw, prefix: true

      delegate *%i[segments], to: :vg
      alias_method :segs, :segments

      def initialize(*args, volume_group:, **kwargs)
        @volume_group = volume_group
        super(*args, **kwargs)
      end

      def used = ByteSize.bytes(raw.used)
      def free = ByteSize.bytes(raw.free)
      def size = ByteSize.bytes(raw.size)

      memoize def pv_segments
        raw_segments.map do |raw|
          PhysicalVolumeSegment.new(raw, physical_volume: self, volume_group:, interface:)
        end.tap(&:sort!)
      end
      alias_method :pv_segs, :pv_segments
    end
  end
end
