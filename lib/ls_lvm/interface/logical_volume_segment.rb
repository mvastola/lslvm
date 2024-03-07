# frozen_string_literal: true

module LsLVM
  module Interface
    class LogicalVolumeSegment < BaseSegment
      self.compare_fields = %i[lv start]
      attr_reader :logical_volume
      alias_method :lv, :logical_volume
      delegate *%i[], to: :lv, prefix: true

      def initialize(*args, logical_volume:, **kwargs)
        super(*args, **kwargs)
        @logical_volume = logical_volume
      end

      def size = ByteSize.bytes(raw.size)

      memoize def pv_segs
        raw.devices.split(',').map do |device|
          match = device.match(/\A(?<name>.*)\((?<start>\d+)\)\z/)
          unless match
            raise ArgumentError, "#{match} could not be parsed into a PV and start extent"
          end

          pv = vg.physical_volume(name: match[:name])
          return if match[:name].exclude?('/') && pv.nil?

          raise ResourceNotFound, "#{match} could not find PV in #{vg.name} by #{match.named_captures}" unless pv

          pv.pv_segs.detect { _1.start == match[:start].to_i }
        rescue ResourceNotFound => ex
          warn ex
          nil
        end
      end

      memoize def physical_volumes
        pv_names = raw.devices.split(',').map { _1.sub(/\(\d+\)\z/)}.uniq
        vg.pvs.select { pv_names.include?(_1.name) }.sort
      end
      alias_method :pvs, :physical_volumes



    end
  end
end
