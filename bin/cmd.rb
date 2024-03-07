#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/ls_lvm'

@cmd = LsLVM::Command.new
@cmd.run

pp @lvm
binding.pry # rubocop:todo Lint/Debugger

OLD = <<~BASH_SCRIPT
  declare -a VGS=()
  declare -a PVS=()
  declare -a SEGMENTED_LVS=()
  declare -a PVMOVES=()
  declare -i PVMOVE_DURATION=0
  declare -i ETA_SEC=0
  declare -i ETA_MIN=0
  declare -i ETA_HR=0

  exec 6>&-
  VGS=( $(vgs --noheadings -o vg_name  -O vg_name | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/') )

  for VG in "${VGS[@]}"; do
    PVS=( $(pvs --noheadings -o pv_name -O pv_name -S "vg_name = '${VG}'" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/') )
    echo -e "### Volume Group ${VG} ###\n"
    vgs -o -vg_name "${VG}"
    echo
    lvs -o lv_name,lv_attr,lv_size,seg_count -O lv_name "${VG}"

    SEGMENTED_LVS=( $(lvs --noheadings -o lv_full_name -O lv_full_name -S 'seg_count > 1' "${VG}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/') )
    for SEGMENTED_LV in "${SEGMENTED_LVS[@]}"; do
      echo -e "\nSegments for ${SEGMENTED_LV}:"
      lvs --units 1g -o seg_start_pe,seg_pe_ranges,seg_size_pe,seg_size -O seg_start_pe "${SEGMENTED_LV}"
    done

    for PV in "${PVS[@]}"; do
      PV_USED=$(pvs --noheadings -o pv_used "${PV}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/')
      PV_FREE=$(pvs --noheadings -o pv_free "${PV}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/')
      PV_SIZE=$(pvs --noheadings -o pv_size "${PV}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/')
      #PV_EXTENTS=$(pvs --noheadings -o pv_pe_count "${PV}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/')
      echo -e "\nSegments in ${PV} (used: ${PV_USED}; free: ${PV_FREE}; total: ${PV_SIZE}):"
      #pvs -o pvseg_start,pvseg_size,lv_name,selected -S 'lv_size = 0' "${PV}" | sed -r '1s/^(.*[^[:space:]])[[:space:]]+Selected[[:space:]]*$/ \1/; 2,$s/^(.*[^[:space:]])[[:space:]]+([01])[[:space:]]*$/\2\1/; 2,$s/^0/ /; 2,$s/^1(.*[^[:space:]])[[:space:]]*$/*\1 ** FREE **/'
      pvs -o pvseg_start,pvseg_size,lv_name,selected -S 'lv_size = 0' "${PV}" | \
        sed -r '1s/^(.*)Selected[[:space:]]*$/  \1/' | \
        sed -r '2,$s/^(.*[^[:space:]])[[:space:]]*0[[:space:]]*$/  \1/' |\
        sed -r '2,$s/^(.*[^[:space:]])[[:space:]]*1[[:space:]]*$/* \1 ** FREE **/'
    done

    PVMOVES=( $(lvs --noheadings -a -o lv_full_name -S "move_pv != ''" "${VG}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/') )
    [ ${#PVMOVES[@]} -gt 0 ] || continue
    echo -e "\nPhysical Volume Migration(s) in Progress:"
    lvs -a -o lv_name,seg_size,seg_size_pe,copy_percent,move_pv,seg_pe_ranges -O lv_name -S "move_pv != ''" "${VG}"
    #PVMOVE_TMP="$(tempfile -d /tmp)"
    #PVMOVE_HEADER="$(lvs --separator ',' -a -o lv_name,seg_size,seg_size_pe,copy_percent,move_pv,seg_pe_ranges -O lv_name -S "move_pv != ''" "${VG}" | head -n1)"
    #PVMOVE_HEADER="${PVMOVE_HEADER},Start Time,ETA"
    #trap "rm -f '${PVMOVE_TMP}'" ERR EXIT TERM QUIT ABRT
    #for PVMOVE in "${PVMOVES[@]}"; do
    #  PVMOVE_DATA="$(lvs --separator ',' -a -o lv_name,seg_size,seg_size_pe,lv_time,copy_percent,move_pv,seg_pe_ranges -O lv_name "${PVMOVE}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/' )"
    #  PVMOVE_START="$(lvs -a -o lv_time "${PVMOVE}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/' )"
    #  PVMOVE_PCT="$(lvs -a -o copy_percent "${PVMOVE}" | sed -r 's/^[[:space:]]*(.*)[[:space:]]*$/\1/' )"
    #  PVMOVE_DURATION=$(( $(date +"%s") - $(date --date="${PVMOVE_START}" +"%s") ))
    #  ETA_SEC=$(echo "(1 - ${PVMOVE_PCT}/100 ) * ${PVMOVE_DURATION}" | bc -l)
    #  let 'ETA_MIN = ETA_SEC / 60' 'ETA_SEC = ETA_SEC % 60'
    #  let 'ETA_HR = ETA_MIN / 60' 'ETA_MIN = ETA_MIN % 60'
    #  ETA_STR="${ETA_HR}h ${ETA_MIN}m ${ETA_SEC}s"
    #  #>> "${PVMOVE_TMP}"
    #done
    #lvs -a -o lv_name,seg_size,seg_size_pe,lv_time,copy_percent,move_pv,seg_pe_ranges -O lv_name -S "move_pv != ''" "${VG}"
    #echo -e "\nPhysical Volume Migration(s) in Progress:"
    #cat "${PVMOVE_TMP}"
    #rm -f "${PVMOVE_TMP}"
  done
  }
BASH_SCRIPT
