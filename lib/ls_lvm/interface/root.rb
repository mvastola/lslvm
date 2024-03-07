# frozen_string_literal: true

module LsLVM
  module Interface
    class Root
      class << self
        include Memery
        memoize def cmd
          [LsLVM.sudo, LsLVM.exe].freeze
        end
      end

      include Memery
      attr_reader :debug

      def initialize(debug: false)
        @debug = debug
      end

      memoize def lvm
        LVM::LVM.new(command: self.class.cmd.shelljoin, debug:, additional_arguments: %w[-a])
      end

      memoize def volume_groups
        lvm.volume_groups.map do |vg_raw|
          VolumeGroup.new(vg_raw, interface: self)
        end.tap(&:sort!)
      end
      alias_method :vgs, :volume_groups

      def volume_group(**kwargs)
        unless kwargs.present?
          raise ArgumentError, 'VolumeGroup search arguments must be specified'
        end

        volume_groups.select { _1.matches?(**kwargs) }.sole
      end
      alias_method :vg, :volume_group

      def pretty_print_instance_variables
        super.without(*%i[@_memery_memoized_values interface])
      end
    end
  end
end
