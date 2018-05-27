#!/bin/bash

#      ___    __                __
#     /   |  / /_  ____  __  __/ /_
#    / /| | / __ \/ __ \/ / / / __/
#   / ___ |/ /_/ / /_/ / /_/ / /_
#  /_/  |_/_.___/\____/\__,_/\__/
#
#  Shell script to prepare the system for running WebLogin.
#
#
#  AUTHOR   Catrine Ibsen
#  DATE     2018-05-06
#
#
#  OPTIONS           DEFAULT VALUE     COMMENT
#  -d [dir]          Current (.)       Installation directory.
#  -f [version]      Latest version    Specify verison of Firefox.
#  -g [URL]          Latest version    URL to desired version of geckodriver.
#  -s [version]      Latest version    Specify version of Selenium.
#                                      Wildcards can be used, i.e. 3.11.*
#  -v [True/False]   True              Use Python virtual environment.
#                                      If True, this script will change the
#                                      shebang for weblogin.
#
#
#  EXIT VALUES
#  0  Success
#  1  Error
#  2  Must be run as root
#  3  Script only works on Ubuntu and Debian


#   _    __           _       __    __
#  | |  / /___ ______(_)___ _/ /_  / /__  _____
#  | | / / __ `/ ___/ / __ `/ __ \/ / _ \/ ___/
#  | |/ / /_/ / /  / / /_/ / /_/ / /  __(__  )
#  |___/\__,_/_/  /_/\__,_/_.___/_/\___/____/

# Get arguments.
while getopts d:f:g:s:v: option;do
    case ${option}
        in
        d) INSTALL_DIR=${OPTARG};;
        f) FIREFOX_VERSION=${OPTARG};;
        g) GECKO_URL=${OPTARG};;
        s) SELENIUM_VERSION=${OPTARG};;
        v) VIRTUALENV=${OPTARG};;
    esac
done

# Test property of -v
if [[ -z ${VIRTUALENV} ]] || [[ ${VIRTUALENV} == [Tt]rue ]];then
    VIRTUALENV='True'
else
    VIRTUALENV='False'
fi

OS=$(cat /etc/os-release | grep -E ^NAME= | cut -c 6-)
GECKO_ADDRESS='https://github.com/mozilla/geckodriver/releases'
FIREFOX_ADDRESS="https://download.mozilla.org/?product=\
firefox-latest-ssl&os=linux64&lang=en-US"
INSTALL_LIST="python3 \
              python3-pip \
              virtualenv"
INSTALL_LIST_DEBIAN=${INSTALL_LIST}" \
                    bzip2 \
                    curl \
                    libgtk-3-0 \
                    libnss3 \
                    libvpx4 \
                    libdbus-glib-1-2 \
                    libxt6"

# Specify download link for Firefox if given by user.
if [[ -n ${FIREFOX_VERSION} ]];then
    FIREFOX_ADDRESS=https://ftp.mozilla.org/pub/firefox/releases\
/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2
fi

# Assign current directory (.) as installation directory if not specified.
if [[ -z ${INSTALL_DIR} ]];then
    INSTALL_DIR=$(pwd)
fi

# Create directory for downloads if not present.
DOWNLOAD_DIR=${INSTALL_DIR}/download
if [[ ! -d ${DOWNLOAD_DIR} ]];then
    mkdir ${DOWNLOAD_DIR}
fi


#      ______                 __  _
#     / ____/_  ______  _____/ /_(_)___  ____  _____
#    / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
#   / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
#  /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

test_root () {
  # Test if the script is run as root.
    if [[ $(id -u) != 0 ]];then
        echo "This script must be executed with root privilegies"
        exit 2
    fi
}


install_program () {
    PROGRAM=$1
    # Test if the program is present in $PATH. If absent it will be installed.
    STATUS=$(which ${PROGRAM})
    if [[ -z ${STATUS} ]];then
        echo "  Installing ${PROGRAM}"
        apt-get install ${PROGRAM} -y > /dev/null
    else
        echo "  ${PROGRAM} is already installed"
    fi
}


install_firefox () {
    PRESENT_FF_VERSION=$(firefox --version 2> /dev/null | awk '{print $3}')
    # Remove Firefox ESR if installed.
    if [[ -f /usr/lib/firefox-esr ]];then
        apt-get purge firefox-esr -y
    fi
    if [[ -z ${PRESENT_FF_VERSION} ]] && [[ -z ${FIREFOX_VERSION} ]];then
	# Assign latest version for download if not installed or user has not made a choice.
        FIREFOX_ADDRESS="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
    elif [[ -n ${PRESENT_FF_VERSION} ]] && [[ -z ${FIREFOX_VERSION} ]];then
	# Do not install Firefox and exit this function.
        echo "  Firefox is already installed"
	echo "  To choose a different version, use the -f option"
	echo "  Example: prep_weblogin.sh -f 59.0.2"
	return
    fi
    # Install Firefox. 
    echo "  Downloading Firefox"
    if [[ ! -f /usr/bin/firefox ]];then
        ln -s /usr/lib/firefox/firefox /usr/bin/firefox
    fi
    wget -q ${FIREFOX_ADDRESS} -O ${DOWNLOAD_DIR}/firefox.tar.bz2
    tar jxf ${DOWNLOAD_DIR}/firefox*.tar.bz2 -C /usr/lib/
    if [[ ! -f /usr/bin/firefox ]];then
        ln -s /usr/lib/firefox/firefox /usr/bin/firefox
    fi
}


installer () {
    if [[ ${OS} = '"Ubuntu"' ]];then
        if [[ -z ${FIREFOX_VERSION} ]];then
            # Install latest version of Firefox.
            INSTALL_LIST=${INSTALL_LIST}" firefox"
        else
            echo "  Downloading Firefox"
            if [[ ! -f /usr/bin/firefox ]];then
                ln -s /usr/lib/firefox/firefox /usr/bin/firefox
            fi
            wget -q ${FIREFOX_ADDRESS} -O ${DOWNLOAD_DIR}/firefox.tar.bz2
            tar jxf ${DOWNLOAD_DIR}/firefox*.tar.bz2 -C /usr/lib/
            if [[ ! -f /usr/bin/firefox ]];then
                ln -s /usr/lib/firefox/firefox /usr/bin/firefox
            fi
        fi
    elif [[ ${OS} = '"Debian GNU/Linux"' ]];then
        # Add packets for Debian to installation list.
        INSTALL_LIST=${INSTALL_LIST_DEBIAN}
        install_firefox
    else
        echo "Sorry, but this script only works on Ubuntu and Debian"
        exit 3
    fi

    # Install needed packages for the system.
    for program in ${INSTALL_LIST};do
        install_program ${program}
    done
}


configure_virtualenv () {
    # Install Python virtual environment if set to True.
    # Selenium will be installed inside the virtual environment.
    if [[ ${VIRTUALENV} == 'True' ]];then
        echo "  Make weblogin.py use ${INSTALL_DIR}/bin/python3"
        SHEBANG=\#\!"${INSTALL_DIR//\//'\/'}\/bin\/python3"
        sed -i "1s/.*/${SHEBANG}/" weblogin.py
        echo "  Creating a virtual environment for weblogin.py"
        virtualenv -p python3 ${INSTALL_DIR}
        source ${INSTALL_DIR}/bin/activate
    fi
    # Install Selenium.
    if [[ -z ${SELENIUM_VERSION} ]];then
        echo "  Installing Selenium"
        pip3 install selenium 2> /dev/null
    else
        echo "  Installing Selenium version ${SELENIUM_VERSION}"
        pip3 install "selenium'=='${SELENIUM_VERSION}" 2> /dev/null
    fi
}


install_geckodriver () {
# Get URL for geckodriver if not specified.
    if [[ -z ${GECKO_URL} ]];then
        GECKO_URL=${GECKO_ADDRESS}
        GECKO_VERSION=$(curl -i --silent ${GECKO_ADDRESS}/latest | \
                        grep '<body>' | \
                        grep -oE v[0-9].[0-9]{2}.[0-9])
        GECKO_FILE="geckodriver-${GECKO_VERSION}-linux64.tar.gz"
        GECKO_URL="${GECKO_URL}/download/${GECKO_VERSION}/${GECKO_FILE}"
	echo $GECKO_URL
    else
        GECKO_FILE=$(echo ${GECKO_URL//\//' '} | awk '{print $8}')
        GECKO_VERSION=$(echo ${GECKO_URL//\//' '} | \
                        grep -oE v[0-9].[0-9]{2}.[0-9] | \
                        head -1)
    fi

exit
    # Download and install geckodriver.
    if [[ ! -f ${DOWNLOAD_DIR}/${GECKO_FILE} ]];then
        echo "  Downloading and unpacking GeckoDriver ${GECKO_VERSION}"
        wget -q ${GECKO_URL} -P ${DOWNLOAD_DIR}/
        tar xf ${DOWNLOAD_DIR}/${GECKO_FILE} -C ${INSTALL_DIR}/bin/
        if [[ -f ${INSTALL_DIR}/bin/geckodriver ]];then
            echo "  GeckoDriver ${GECKO_VERSION} is now in ${INSTALL_DIR}/bin"
        else
            echo "  Error installing GeckoDriver"
        fi
    else
        echo "  GeckoDriver ${GECKO_VERSION} is already present"
    fi
}


#      ______                     __  _
#     / ____/  _____  _______  __/ /_(_)___  ____ 
#    / __/ | |/_/ _ \/ ___/ / / / __/ / __ \/ __ \
#   / /____>  </  __/ /__/ /_/ / /_/ / /_/ / / / /
#  /_____/_/|_|\___/\___/\__,_/\__/_/\____/_/ /_/

#test_root
installer
#configure_virtualenv
#install_geckodriver