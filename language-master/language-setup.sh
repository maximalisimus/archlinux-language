#!/bin/bash
#
# Architect Installation Framework (version 1.6.4 - 08-Sep-2019)
# Create a temporary file to store menu selections
ANSWER="/tmp/.aif"
ABSOLUT_FILENAME=$(readlink -e "$0")
filesdir=$(dirname "$ABSOLUT_FILENAME")
_how_shell=$(echo "$SHELL" | rev | cut -d '/' -f1 | rev | tr '[:upper:]' '[:lower:]')
# Save retyping
VERSION="MAXIMALISIMUS Installation Framework 2.5"
# list of variables
source "$filesdir/dialogrc-conf.sh"
source "$filesdir/installer-variables.sh"
source "$filesdir/dependences_function.sh"
FONT=""
CURR_LOCALE=""
_sethwclock=""
ZONE=""
SUBZONE=""
# Add locale on-the-fly and sets source translation file for installer
select_language() {
    
    dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title " Select Language " --menu "\nLanguage / sprache / taal / språk / lingua / idioma / nyelv / língua" 0 0 11 \
    "1" $"English       (en)" \
    "2" $"Italian       (it)" \
    "3" $"Russian       (ru)" \
    "4" $"Turkish       (tr)" \
    "5" $"Dutch         (nl)" \
    "6" $"Greek         (el)" \
    "7" $"Danish        (da)" \
    "8" $"Hungarian     (hu)" \
    "9" $"Portuguese    (pt)" \
   "10" $"German        (de)" \
   "11" $"French        (fr)" 2>${ANSWER}

    case $(cat "${ANSWER}") in
        "1") source "$filesdir"/lang/english.trans
             CURR_LOCALE="en_US.UTF-8"
             ;;
        "2") source "$filesdir"/lang/italian.trans
             CURR_LOCALE="it_IT.UTF-8"
             ;; 
        "3") source "$filesdir"/lang/russian.trans
             CURR_LOCALE="ru_RU.UTF-8"
             FONT="LatKaCyrHeb-14.psfu"
             ;;
        "4") source "$filesdir"/lang/turkish.trans
             CURR_LOCALE="tr_TR.UTF-8"
             FONT="LatKaCyrHeb-14.psfu"
             ;;
        "5") source "$filesdir"/lang/dutch.trans
             CURR_LOCALE="nl_NL.UTF-8"
             ;;             
        "6") source "$filesdir"/lang/greek.trans
             CURR_LOCALE="el_GR.UTF-8"
             FONT="iso07u-16.psfu"       
             ;;
        "7") source "$filesdir"/lang/danish.trans
             CURR_LOCALE="da_DK.UTF-8"
             ;;   
        "8") source "$filesdir"/lang/hungarian.trans
             CURR_LOCALE="hu_HU.UTF-8"
             FONT="lat2-16.psfu"
             ;;
        "9") source "$filesdir"/lang/portuguese.trans
             CURR_LOCALE="pt_BR.UTF-8"    
             ;;      
       "10") source "$filesdir"/lang/german.trans
             CURR_LOCALE="de_DE.UTF-8"
             ;;
       "11") source "$filesdir"/lang/french.trans
             CURR_LOCALE="fr_FR.UTF-8"
             ;;
          *) exit 0
             ;;
    esac
}
# locale array generation code adapted from the Manjaro 0.8 installer
set_locale() {
      
  sed -i '/^[a-z]/s/^/#/g' /etc/locale.gen
  
  LOCALES=""    
  for i in $(cat /etc/locale.gen | grep -v "#  " | sed 's/#//g' | sed 's/ UTF-8//g' | grep .UTF-8); do
      LOCALES="${LOCALES} ${i} -"
  done

  dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_LocateTitle" --menu "$_localeBody" 0 0 16 ${LOCALES} 2>${ANSWER} || config_base_menu 
  LOCALE=$(cat ${ANSWER})
  
  _KEYMAP=$(echo "${LOCALE[*]}" | sed 's/_.*//')
  
  clear
  echo "LANG=\"${LOCALE}\"" > /etc/locale.conf
  echo "LC_MESSAGES=\"${LOCALE}\"" >> /etc/locale.conf
  sed -i "s/#${LOCALE}/${LOCALE}/" /etc/locale.gen
  loadkeys ${_KEYMAP}
  echo "LOCALE=\"${LOCALE}\"" > /etc/vconsole.conf
  echo "KEYMAP=\"${_KEYMAP}\"" >> /etc/vconsole.conf
  [[ ${_KEYMAP} =~ ^(ru) ]] && FONT="cyr-sun16"
  if [[ $FONT != "" ]]; then
    echo "FONT=\"${FONT}\"" >> /etc/vconsole.conf
    echo "CONSOLEFONT=\"${FONT}\"" >> /etc/vconsole.conf
    setfont ${FONT}
  else
    echo "FONT=\"cyr-sun16\"" >> /etc/vconsole.conf
    echo "CONSOLEFONT=\"cyr-sun16\"" >> /etc/vconsole.conf
    setfont cyr-sun16
  fi
  echo "USECOLOR=\"yes\"" >> /etc/vconsole.conf
  locale-gen
  export Lang="${LOCALE}"
  [[ ${ZONE[*]} != "" ]] && [[ ${SUBZONE[*]} != "" ]] && echo "TIMEZONE=\"${ZONE}/${SUBZONE}\"" >> /etc/vconsole.conf
  [[ ${_sethwclock[*]} != "" ]] && echo "HARDWARECLOCK=\"${_sethwclock}\"" >> /etc/vconsole.conf
  echo "CONSOLEMAP=\"\"" >> /etc/vconsole.conf
}

# Set Zone and Sub-Zone
set_timezone() {

    ZONE=""
    for i in $(cat /usr/share/zoneinfo/zone.tab | awk '{print $3}' | grep "/" | sed "s/\/.*//g" | sort -ud); do
      ZONE="$ZONE ${i} -"
    done
    
     dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_TimeZTitle" --menu "$_TimeZBody" 0 0 10 ${ZONE} 2>${ANSWER}
     ZONE=$(cat ${ANSWER}) 
    
     SUBZONE=""
     for i in $(cat /usr/share/zoneinfo/zone.tab | awk '{print $3}' | grep "${ZONE}/" | sed "s/${ZONE}\///g" | sort -ud); do
        SUBZONE="$SUBZONE ${i} -"
     done
         
     dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_TimeSubZTitle" --menu "$_TimeSubZBody" 0 0 11 ${SUBZONE} 2>${ANSWER}
     SUBZONE=$(cat ${ANSWER}) 
    
     dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --yesno "$_TimeZQ ${ZONE}/${SUBZONE} ?" 0 0 
     
     if [[ $? -eq 0 ]]; then
        ln -s /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime
     fi
}

set_hw_clock() {
    
   dialog --backtitle "$VERSION - $SYSTEM ($ARCHI)" --title "$_HwCTitle" \
    --menu "$_HwCBody" 0 0 2 \
    "1" "$_HwCUTC" \
    "2" "$_HwLocal" 2>${ANSWER} 

    case $(cat ${ANSWER}) in
        "1") hwclock --systohc --utc
                _sethwclock="utc"
             ;;
        "2") hwclock --systohc --localtime
                _sethwclock="localtime"
             ;;
     esac 
}
setcolor
if [[ "${_how_shell[*]}" != "fish" ]]; then
    dialog 1>/dev/null 2>/dev/null
    if [[ $? != "0" ]]; then
        script_dependences_question
        dependences_result
    fi
else
    dialog 1>/dev/null 2>/dev/null
    if [[ "$STATUS" != "0" ]]; then
        script_dependences_question
        dependences_result
    fi
fi
us_dlgrc_conf
select_language
set_timezone
set_hw_clock
set_locale
rm -rf ${ANSWER}
un_us_dlgrc_conf
exit 0
