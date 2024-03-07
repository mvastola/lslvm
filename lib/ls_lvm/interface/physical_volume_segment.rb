# frozen_string_literal: true

module LsLVM
  module Interface
    class PhysicalVolumeSegment < BaseSegment
      self.compare_fields = %i[pv start]
      attr_reader :physical_volume
      alias_method :pv, :physical_volume
      delegate *%i[], to: :pv, prefix: true

      def initialize(*args, physical_volume:, **kwargs)
        super(*args, **kwargs)
        @physical_volume = physical_volume
      end

      memoize def pe_range
        pe_span = [start, finish - 1].uniq
        "#{pv_name}:#{pe_span.map(&:to_s).join('-')}".freeze
      end

      memoize def lv_seg
        pv.vg.lvs.flat_map(&:lv_segs).detect do |possible_lv_seg|
          next if possible_lv_seg.pv_segs.blank?

          possible_lv_seg.pv_segs.include?(self)
        end
      end

      # def <=>(*args, **kwargs)
      #   binding.pry
      #   super
      # end
    end
  end
end
