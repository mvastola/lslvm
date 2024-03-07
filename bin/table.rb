#!/usr/bin/env ruby
# frozen_string_literal: true

require 'debug'
require_relative '../lib/ls_lvm'

class TerminalTable
  class << self
    def header(text)
      puts ('#' * 10) + (' ' * 2) + text + (' ' * 2) + ('#' * 10)
    end
    # def title(title) = show(title:)

    def show(headings: nil, singles: nil, title: nil, &block)
      table = Terminal::Table.new do |t|
        t.title = title
        t.headings = Array.wrap(headings)
        t.rows = []
        t.style = { border: :unicode_round } # >= v3.0.0
        Array.wrap(singles).each { t.add_row(Array.wrap(_1)) }
        block&.call t
        nil
      end
      puts table
    end
  end
end

@lvm = LsLVM::Interface::Root.new


# 4   8   0 wz--n- 39.12t <15.40t

TerminalTable.show(title: 'Volume Groups', singles: @lvm.vgs.map(&:name))

@lvm.vgs.each do |vg|
  TerminalTable.show(title: vg.name, headings: %w[#PV #LV #SN Attr VSize VFree]) do |t|
    row = []
    row << vg.physical_volumes.count
    row << vg.logical_volumes.count
    row << vg.snap_count
    row << vg.attr
    row << vg.size.to_s(2)
    row << vg.free.to_s(2)
    t.add_row row
  end

  TerminalTable.show(headings: %w[LV Attr LSize #Seg], title: 'Logical Volumes') do |t|
    vg.lvs.each do |lv|
      t.add_row [lv.display_name, lv.attr, lv.size.to_s(2), lv.seg_count]
    end
  end

  vg.lvs.each do |lv|
    pe_segs = lv.lv_segs
    next if pe_segs.count <= 1

    puts "Segments for #{vg.name}/#{lv.display_name}:"
    TerminalTable.show(headings: ['Start', 'PV Ranges', 'PESize', 'SSize']) do |t|
      pe_segs.each do |seg|
        t.add_row [seg.start_pe, seg.pe_ranges, seg.size_pe, seg.size.to_s(2)]
      end
    end
  end

  vg.pvs.each do |pv|
    pe_segs = pv.pv_segs
    puts "Segments in #{pv.name} (used: #{pv.used.to_s(2)}; free: #{pv.free.to_s(2)}; total: #{pv.size.to_s(2)}):"
    next if pe_segs.empty?

    TerminalTable.show(headings: %w[Start SSize LV]) do |t| # , ''
      pe_segs.each do |seg|
        binding.pry if pv.name == '/dev/sde1'
        t.add_row [seg.start, seg.size, seg.lv_seg&.lv&.display_name] # , 'selected?']
      end
    end
  end
end

exit

# PVMOVES=( $(lvs --noheadings -a -o lv_full_name -S "move_pv != ''" "${VG}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/') )
# echo -e "\nPhysical Volume Migration(s) in Progress:"
# lvs -a -o lv_name,seg_size,seg_size_pe,copy_percent,move_pv,seg_pe_ranges -O lv_name -S "move_pv != ''" "${VG}"



# Terminal::Table.new :title => "Cheatsheet", :headings => ['Word', 'Number'], :rows => rows
# table = Terminal::Table.new :title => "Cheatsheet", :headings => ['Word', 'Number'], :rows => rows

# table = Terminal::Table.new do |t|
#   t.style = { :border => :unicode_round } # >= v3.0.0
#   t.title = "Some Title"
#   t.headings = csv_array[0]
#   t.rows = csv_array[1..-1]
# end
