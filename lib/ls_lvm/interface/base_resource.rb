# frozen_string_literal: true

module LsLVM
  module Interface
    class BaseResource
      include Memery
      include Comparable
      class_attribute :compare_fields, default: [], instance_accessor: false
      self.compare_fields = %i[name]

      attr_reader :interface
      delegate :lvm, to: :interface

      def initialize(interface:)
        @interface = interface
      end

      # Aliases, but will still error at runtime if not defined
      # def vgs(...) = volume_groups(...)
      # def vg(...) = volume_group(...)
      # def lvs(...) = logical_volumes(...)
      # def lv(...) = logical_volume(...)
      # def pvs(...) = physical_volumes(...)
      # def pv(...) = physical_volume(...)

      def matches?(other: nil, **kwargs)
        return self == other if other.is_a?(self.class)

        raise ArgumentError, "Search arguments must be specified for #{self}" \
          unless kwargs.present?

        kwargs.all? do |field, value|
          send(field.to_sym) == value
        end
      end

      def <=>(other) # rubocop:disable Metrics/AbcSize
        if !other.is_a?(self.class)
          raise ArgumentError, "Incompatible objects (#{self.class} and #{other.class})"
        elsif self.class.compare_fields.blank?
          raise "Comparable fields not defined for #{self.class}"
        end

        self.class.compare_fields.each do |field|
          result = send(field.to_sym) <=> other.send(field.to_sym)
          return result unless result.zero?
        end
        0
      end

      def pretty_print_instance_variables
        super.without(*%i[@_memery_memoized_values instance @interface lvm])
      end
    end
  end
end
