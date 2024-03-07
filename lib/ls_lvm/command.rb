# frozen_string_literal: true

module LsLVM
  class Command
    include Memery
    include Commander::Methods

    attr_reader :dsl

    def run
      always_trace!

      program :name, 'lslvm'
      program :version, '0.1.0'
      program :summary, 'Describe LVM pvs/vgs/lvs in tabular format'
      program :help, 'Author', 'Mike Vastola <Mike@Vasto.la>'
      program :help_formatter, Commander::HelpFormatter::Terminal

      global_option '--verbose', '-v', 'Show verbose information'
      global_option '--unit UNIT', '-u UNIT', 'Specify file size unit for display'

      command :show do |c|
        c.syntax = 'show'
        c.description = 'List lvm objects'
        # c.option '--interval SECONDS', Integer, 'Interval in seconds'

        c.action do |args, options|
          # options.default :interval => 2, :timeout  => 60
          @dsl = LsLVM::Interface::Root.new(**options)
        end
      end
      default_command :show
    end
  end
end

# ### Volume Group VastDesk ###
#
#   #PV #LV #SN Attr   VSize  VFree
#     4   8   0 wz--n- 39.12t <14.90t
#
#   LV            Attr       LSize   #Seg
#   Boot          -wc-ao----   2.50g    1
#   DataStore     -wI-ao----   4.00t    3
#   ExternalStore -wc-ao----  18.00t    2
#   RootOS        rwc-aor--- 436.45g    1
#   Swap          -wc-ao----  32.00g    1
#   VMs           -wi-ao---- 200.00g    1
#   VMsOld        -wi-a----- 150.00g    1
#   phone-backup  -wi-a----- 512.00g    1
#
# Segments for VastDesk/DataStore:
#   Start  PE Ranges                 SSize  SSize
#        0 pvmove0:0-131071          131072  512.00g
#   131072 /dev/sde1:1048576-1835007 786432 3072.00g
#   917504 /dev/sde1:917504-1048575  131072  512.00g
#
# Segments for VastDesk/ExternalStore:
#   Start   PE Ranges                 SSize   SSize
#         0 /dev/sdd1:0-4291582       4291583 16764.00g
#   4291583 /dev/sda1:1160310-1587318  427009  1668.00g
#
# Segments in /dev/sda1 (used: <3.06t; free: 6.04t; total: <9.10t):
#     Start   SSize  LV
#           0      1 [RootOS_rmeta_1]
#           1 111732 [RootOS_rimage_1]
#      111733 131072 [pvmove0]
# *    242805 786433 ** FREE **
#     1029238 131072 phone-backup
#     1160310 427009 ExternalStore
# *   1587319 797064 ** FREE **
#
# Segments in /dev/sdc5 (used: <820.96g; free: <125.00g; total: 945.95g):
#     Start  SSize  LV
#          0    640 Boot
#        640  38400 VMsOld
#      39040      1 [RootOS_rmeta_0]
#      39041  51200 VMs
# *    90241  31999 ** FREE **
#     122240 111732 [RootOS_rimage_0]
#     233972   8192 Swap
#
# Segments in /dev/sdd1 (used: 16.37t; free: 0 ; total: 16.37t):
#     Start SSize   LV
#         0 4291583 ExternalStore
#
# Segments in /dev/sde1 (used: 4.00t; free: 8.73t; total: 12.73t):
#     Start   SSize   LV
#           0  131072 [pvmove0]
# *    131072  786432 ** FREE **
#      917504  131072 DataStore
#     1048576  786432 DataStore
# *   1835008 1502975 ** FREE **
#
# Physical Volume Migration(s) in Progress:
#   LV        SSize   SSize  Cpy%Sync Move      PE Ranges
#   [pvmove0] 512.00g 131072 45.72    /dev/sda1 /dev/sda1:111733-242804 /dev/sde1:0-131071
