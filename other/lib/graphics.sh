#! /bin/sh
# -----------------------------------------------------------------------
# Apk Manager OS X v3.0+
# Colors and graphics definition file
#
# by Jocelyn Mallon CC by-nc-sa 2012
# http://girlintroverted.wordpress.com
#
# version: 3.2b
# Wed. Aug 7, 2013
# -----------------------------------------------------------------------

# define colors for pretty output
red='\033[0;31m'
bred='\033[1;31m'
green='\033[0;32m'
bgreen='\033[1;32m'
blue='\033[0;34m'
bblue='\033[1;34m'
pink='\033[0;35m'
bpink='\033[1;35m'
yellow='\033[0;33m'
byellow='\033[1;33m'
rclr='tput sgr0'

# set some graphical variables for easy pretty menus and logs
apkmspr="----------------------------------------------------------------------------------------------------"
apkmftr="****************************************************************************************************"
logspr2="**************************************************"
logspcr="--------------------------------------------------"

# version banner display function
version_banner () {
    local vernum
    local apkstring
    local title_len
    local title_fill
    vernum="$(awk '/# version:/ { print $3; exit}' "${maindir}/other/main.sh")"
    if [[ $(( ${#vernum} % 2)) -eq '0' ]]; then
        apkstring="APK Manager Mac OS X v${vernum}"
    else
        apkstring="APK Manager Mac OSX v${vernum}"
    fi
    title_len="${apkstring//[*]}"
    title_len="${#apkstring}"
    title_fill="$(printf "%*s" $(((98-${title_len})/2)))"
    echo $bgreen"${title_fill// /*}\c"
    echo " ${apkstring} \c"
    echo $bgreen"${title_fill// /*}"; $rclr;
}

# generate ADB killing on quit status for display
adb_kill_display () {
    if [[ ${adb_kill} -eq 1 ]]; then
        echo $bred"ON"$blue")"; $rclr;
    else
        echo $bgreen"OFF"$blue")"; $rclr;
    fi
}

# generate ADB screenshot enabled status for display
adb_screencap_display () {
    if [[ ${adb_screencap} -eq 1 ]]; then
        echo $bgreen"ON"$blue")"; $rclr;
    else
        echo $bred"OFF"$blue")"; $rclr;
    fi
}

# generate ADB connect on start status for display
adb_connect_start_display () {
    if [[ ${adb_connect_on_start} -eq 1 ]]; then
        echo $bgreen"ON"$blue")"; $rclr;
    else
        echo $bred"OFF"$blue")"; $rclr;
    fi
}

# generate ADB device information for header
gen_adb_device_info () {
    if [[ -n $adb_dev_choice ]] && [[ -n $adb_dev_model ]] && [[ -n $adb_dev_product ]] && [[ -n $adb_dev_device ]]; then
        echo $green"${adb_dev_choice}"$blue" (model: "$green"${adb_dev_model}"$blue" | device: "$green"${adb_dev_device}"$blue" | product: "$green"${adb_dev_product} "$blue")"; $rclr;
    else
        adb_dev_choice="none"
        echo $green"No ADB device connected"
    fi
}

# check if we need to truncate project name for display
gen_project_display_text () {
    local maxlength="$((47 - (${#uscr} + ${#heapy})))"
    if [[ ${#capp} -gt ${maxlength} ]]; then
        local cappoffset="$(( ${#capp} - $((maxlength - ${#trunc_symbol})) ))"
        local newcapp="${trunc_symbol}${capp:$cappoffset:$maxlength}"
        echo "${newcapp}"
    else
        echo "${capp}"
    fi
}

# generate basic debug information for display
gen_debug_display_text () {
    if [[ ${v_mode} -ne 0 ]]; then
        printf "$bred%s"" VERBOSE MODE ENABLED (-v for entire script) "$bwhite" | "
    fi
    if [[ ${t_mode} -ne 0 ]]; then
        printf "$bred%s"" TRACE MODE ENABLED (-x for entire script) "$bwhite" | "
    fi
    if [[ ${e_mode} -ne 0 ]]; then
        printf "$bred%s"" -e"$bwhite" |"
        local emode=5
    fi
    if [[ ${debugstate} -ne 0 ]]; then
        if [[ -z $emode ]]; then
            local emode=0
        fi
        local pidw="$$"
        if [[ -z ${errcode} ]]; then
            errcode=0
            local err_string="${bwhite}| \$?: ${bred}${errcode}"
            local pwdfill=28
        else
            local err_string="${bwhite}| ${bred}${errfunc} ${bwhite}\$?: ${bred}${errcode} ${bwhite}line: ${bred}${errline}"
            local pwdfill=36
        fi
        local maxlength="$((100 - (((((${#errfunc} + ${#errcode}) + ${#errline}) + ${#pidw}) + ${emode} ) + ${pwdfill} )))"
        if [[ ${#PWD} -gt ${maxlength} ]]; then
            local pwdoffset="$(( ${#PWD} - $((maxlength - ${#trunc_symbol})) ))"
            local newpwd="${trunc_symbol}${PWD:$pwdoffset:$maxlength}"
        else
            newpwd="$(pwd)"
        fi
        printf "$bwhite%s"" PID: "$bred"$$"$bwhite" ${err_string}"$bwhite" | Last 'cd': "$bred"${newpwd}\n"; $rclr;
        unset errcode
        unset errline
        unset errfunc
    else
        echo ""
    fi
}

# Main APK Manager header
menu_header () {
    local trunc_symbol="..."
    echo ""
    version_banner
    echo $bwhite" Compression-Level: "$bgreen"${uscr}"$bwhite"  |  Heap Size: "$bgreen"${heapy}""mb"$bwhite"  |  Project:"$bgreen $(gen_project_display_text); $rclr;
    echo $bgreen"$apkmspr"; $rclr;
    gen_debug_display_text
}

# Debug/settings menu sub-header
debug_header () {
    if [[ -z $adb_dev_choice ]] && [[ -z $adb_dev_model ]] && [[ -z $adb_dev_product ]]; then
        get_saved_adb_device
    fi
    echo $bgreen"------------------------------------"$bwhite"Debug Info and Misc Settings"$bgreen"------------------------------------";
    echo $white" Current System: "$green"Mac OS X ${osx_ver} ${osx_bld} ${arch_ver}";
    echo $white" APK Manager install type: "$green"${installtype}";
    echo $white" APK Manager root dir: "$green"${maindir}";
    echo $white" ANDROID_SDK_ROOT: "$green"${ANDROID_SDK_ROOT}";
    echo $white" Selected ADB Device:" $(gen_adb_device_info);
    echo $white" Current log viewer: "$green"${logapp}";
    echo $white" Current \"png\" tool: "$green"${pngtool}";
    echo $white" Current APKtool: "$green"${apktool_ver}"$blue" ($(basename "$(readlink "${libdir}/apktool.jar")"))";
}

# automatic updates menu header
updates_header () {
    echo $bgreen"-------------------------------------"$bwhite"Automatic Updates Settings"$bgreen"-------------------------------------";
    local updatestate="$(defaults read "${plist}" updates 2>/dev/null)"
    if [[ $? -ne 0 ]]; then
        updatestate=0
        local key="updates"
        local value="false"
        write_preference
    fi
    if [[ ${updatestate} -eq 1 ]]; then
        update_branch_check
        local commit
        commit="$(get_commit_ver)"
        commit="${commit:0:8}"
        commit="${commit} $(echo $blue"(")$(git log --pretty=format:"%s" --max-count=1)$(echo ")")"
        update_prompt_state
        if [[ ${upromptstate} -eq 1 ]]; then
            local uprompt="${green}ON"
        else
            local uprompt="${bred}OFF"
        fi
        build_last_date_time
        check_update_freq
        if [[ ${ufreq} -eq 1 ]]; then
            local updfreq="${ufreq} ${white}day"
        elif [[ ${ufreq} -gt 1 ]]; then
            local updfreq="${ufreq} ${white}days"
        fi
        echo $white" Updates status: "$green"ON"; $rclr;
        echo $white" Updates prompt: $uprompt"; $rclr;
        echo $white" Update frequency: "$green"${updfreq}"; $rclr;
        echo $white" Last update check: "$green"${last_check}"; $rclr;
        echo $bgreen"$apkmspr"; $rclr;
        echo $white" Current branch: "$green"${saved_channel}"; $rclr;
        echo $white" Current commit: "$green"${commit}"; $rclr;
    else
        echo $white" Updates status: "$bred"OFF"; $rclr;
    fi
}
