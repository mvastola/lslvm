# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
Oj.mimic_JSON
Oj.optimize_rails

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'LVM'
  inflect.acronym 'PV'
  inflect.acronym 'VG'
  inflect.acronym 'LV'
end

require 'lvm'

module LsLVM
  LIB_DIR = (Pathname.new(__dir__) / 'ls_lvm').freeze

  class << self
    include Memery
    memoize def exe = File.which('lvm').freeze
    memoize def sudo = File.which('sudo').freeze

    def loader
      @loader ||= Zeitwerk::Loader.new.tap do |z|
        z.inflector = ActiveSupport::Inflector
        z.push_dir LIB_DIR, namespace: LsLVM
        z.enable_reloading # need to opt-in before setup
      end
    end
  end
end

LsLVM.loader.setup
