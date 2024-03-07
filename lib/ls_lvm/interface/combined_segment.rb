# frozen_string_literal: true

module LsLVM
  module Interface
    class CombinedSegment < BaseResource
      attr_reader :volume_group
      alias_method :vg, :volume_group

      def initialize(*args, pv_seg: nil, lv_seg: nil, **kwargs)
        super(*args, **kwargs)

        if [pv_seg, lv_seg].all?(&:blank?)
          raise ArgumentError, 'A PV and/or LV segment must be given.'
        end

        @volume_group = [pv_seg&.vg, lv_seg&.vg].compact.uniq.sole
        @pv_seg = pv_seg unless pv_seg.nil?
        @lv_seg = lv_seg unless lv_seg.nil?
      end

      def physical_volume = pv_seg.physical_volume
      def logical_volume = lv_seg.logical_volume
      alias_method :lv, :logical_volume
      alias_method :pv, :physical_volume

      def matches?(other: nil, **kwargs)
        return [pv_seg, lv_seg].compact.include?(other) if other.is_a?(BaseSegment)

        super(**kwargs)
      end

      def pv_seg
        return @pv_seg if defined?(@pv_seg)

        @pv_seg = vg.pvs.lazy.flat_map(&:segs).detect { _1.matches?(lv_seg) }
      end

      def lv_seg
        return @lv_seg if defined?(@lv_seg)

        @lv_seg = vg.lvs.lazy.flat_map(&:segs).detect { _1.matches?(pv_seg) }
      end
    end
  end
end
