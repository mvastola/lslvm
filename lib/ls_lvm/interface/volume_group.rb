# frozen_string_literal: true

module LsLVM
  module Interface
    class VolumeGroup < Resource
      include Memery
      delegate *%i[logical_volumes physical_volumes], to: :raw, prefix: true

      def size = ByteSize.bytes(raw.size)
      def free = ByteSize.bytes(raw.free)

      memoize def logical_volumes
        raw_logical_volumes.map do |raw|
          LogicalVolume.new(raw, volume_group: self, interface:)
        end.tap(&:sort!).freeze
      end
      alias_method :lvs, :logical_volumes

      def logical_volume(**kwargs)
        raise ArgumentError, 'Search arguments must be specified' unless kwargs.present?

        logical_volumes.detect { _1.matches?(**kwargs) }
      end
      alias_method :lv, :logical_volume

      memoize def physical_volumes
        raw_physical_volumes.map do |raw|
          PhysicalVolume.new(raw, volume_group: self, interface:)
        end.tap(&:sort!).freeze
      end
      alias_method :pvs, :physical_volumes

      def physical_volume(**kwargs)
        raise ArgumentError, 'Search arguments must be specified' unless kwargs.present?

        pvs.detect { _1.matches?(**kwargs) }
      end
      alias_method :pv, :physical_volume

      memoize def segments
        physical_volumes.flat_map(&:pv_segs).map do |pv_seg|
          CombinedSegment.new(pv_seg:, interface:)
        end
      end
      alias_method :segs, :segments

      def segment(**kwargs)
        raise ArgumentError, 'Search arguments must be specified' unless kwargs.present?

        raise NotImplementedError, "Segment lookup not yet implemented"
      end
      alias_method :seg, :segment

    end
  end
end
