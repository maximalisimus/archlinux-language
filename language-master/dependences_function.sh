#!/bin/bash
setcolor()
{
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_NORMAL="echo -en \\033[0;39m"
}
outin_success()
{
    $SETCOLOR_SUCCESS
    echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
    $SETCOLOR_NORMAL
    echo
}
outin_failure()
{
    $SETCOLOR_FAILURE
    echo -n "$(tput hpa $(tput cols))$(tput cub 6)[fail]"
    $SETCOLOR_NORMAL
    echo
}
script_dependences_question()
{
    echo -e -n "\e[1;37mДля работы скрипта требуется пакет «\e[1;34mdialog\e[1;37m».\e[1;33m Установить? (\e[1;32my\e[1;33m/\e[1;31mn\e[1;33m)? \e[0m\n"
    echo -e -n "\e[1;37mНажатие на кнопку «\e[1;34mEnter\e[1;37m» аналогично действию «\e[1;32my\e[1;37m|\e[1;32mY\e[1;37m» - действие по умолчанию. \e[0m\n\n"
    echo -e -n "\e[1;37mThe «\e[1;34mdialog\e[1;37m» package is required for operation.\e[1;33m To install? (\e[1;32my\e[1;33m/\e[1;31mn\e[1;33m)? \e[0m\n"
    echo -e -n "\e[1;37mPressing the «\e[1;34mEnter\e[1;37m» button is similar to the «\e[1;32my\e[1;37m|\e[1;32mY\e[1;37m» action - default action.\e[0m\n"
}
dependences_result()
{
    read item
    case "$item" in
        y|Y) echo -e -n "\e[1;32mПроизводится установка пакета «dialog»...\e[0m"
            outin_success
            echo -e -n "\e[1;32mThe «dialog» package is installed...\e[0m"
            outin_success
            echo ""
            ;;
        n|N) echo -e -n "\e[1;31mРабота скрипта будет прекращена!\e[0m"
            outin_failure
            echo -e -n "\e[1;31mThe script will be terminated!\e[0m"
            outin_failure
            echo ""
            exit 0
            ;;
        *) echo -e -n "\e[1;37mВыполняется действие по умолчанию...\e[0m"
          outin_success
          echo -e -n "\e[1;32mThe default action is executed...\e[0m" 
          outin_success
          echo ""
            ;;
    esac
}
