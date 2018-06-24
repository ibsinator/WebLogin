# WebLogin #
Script for testing accessibility of a web site using Selenium and Firefox.

All steps needed for installing needed components are described below. 
For safety reasons it is recommended to configure Python virtual environment. 



# 1.  Usage #
Arguments can be set from the command line, from a configuration file or a combination of
both. Arguments given on the command line have preference over arguments from a
configuration file. In most examples below, the long format is used for the sake of clarity.

_**Warning!**_ It is not possible to set credentials from a configuration file.


## 1.1.  Options ##
|*Short* | *Long*             | *Value*    |*Default* | *Types*                 | *Comment*                   |
| ------ | ------------------ | -----------|--------- | ----------------------- | --------------------------- |
| `-a`   | `--url`            |            |          |                         | URL to website              |
| `-c`   | `--config`         | CONFIGGILE |          |                         | File path to config file    |
| `-e`   | `--error_page`     | IDENTIFIER |          | `title`, `h1`, `h2`     | Known error page            |
| `-i`   | `--insert_test`    | FILEPATH   |          |                         | File path to extra test     |
| `-l`   | `--login`          | IDENTIFIER |          | `id`, `name`, `link`    | Login button                |
| `-L`   | `--logout`         | IDENTIFIER |          | `name`, `link`, `class` | Logout buttom               |
| `-m`   | `--timer_max`      |            | 35       |                         | Maximal timer               |
| `-n`   | `--timer_warning`  |            | 7        |                         | Value of timer for warning  |
| `-o`   | `--timer_critical` |            | 15       |                         | Value of timer for critical |
| `-p`   | `--pass`           |            |          |                         | Password                    |
| `-s`   | `--login_sso`      | IDENTIFIER |          | `name`, `link`          | Login link for Shibboleth   |
| `-t`   | `--timeout`        |            | 30       |                         | Timeout for login           |
| `-u`   | `--user`           |            |          |                         | Username                    |
| `-x`   | `--id_user`        |            |          |                         | ID for the username form    |
| `-y`   | `--id_pass`        |            |          |                         | ID for the password form    |

Fields where type is available must have type set for the script to work.


## 1.2. Configuration File ##
A value that is not needed must not be present in the configuration file, otherwise the script will
behave unpredictably. Any kind of whitespace is allowed.

Any kind of whitespace is allowed in the configuration file:
```
-u=MyUsername
--username=MyUsername
-u             MyUsername
--username     MyUsername
--error_page   'My Failed Site'    title
```


## 1.3. Return Values ##
Return values are compatible with the Nagios API.
A return value has the following format, where only the part before the pipe symbol ( | ) will
be visible in Nagios:

```
STATUS: Message | Time=1;2;3;4
```
Return values

| *Code* | *Message*                         |
| :----: | :---------------------------------|
| 0      | OK: Login successful              |
| 1      | WARNING: Redirected to error page |
| 2      | CRITICAL: Login failed            |
| 3      | UNKNOWN: Monitoring script failed |

Time values

| *Pos.* | *Timer Value*             |
| :----: | ------------------------- |
| 1      | Runtime for login attempt |
| 2      | Threshold for warning     |
| 3      | Threshold for critical    |
| 4      | Max value                 |



## 1.4. Examples ##
All arguments from the command line:

```
./weblogin.py --url http://www.example.com \
              --error_page 'Sorry, the site is down' h1 \
              --username MyName \
              --password MyS3cret \
              --id_user username \
              --id_pass password \
              --login LoginClass class \
              --logout Logout link
```

Using a configuration file, username and password must still be set on the command line:
```
./weblogin.py --username MyName --password MyS3cret -c TestSite.conf
```

Configuration file:
```
--url              http://www.example.com
--error_page       'Sorry, the site is down'    h1
--id_user          username-field
--id_pass          password-field
--login            LoginClass                   class
--logout           Logout                       link
--timer_critical   20
--insert_test      extraconfig/extra.py
```


# 2. Prerequisities #

### 2.1.1. Install these packages using some packet manager ###
* python3
* python3-pip
* firefox (firefox-esr of iceweasel for Debian)
* virtualenv

Example using apt on Ubuntu:
```
sudo apt install python3 python3-pip firefox virtualenv
```

Exmple using yum on CentOS:
```
sudo yum install python3 python3-pip firefox virtualenv
```


### 2.1.2. Create a virtual environment and activate it ###
For safety reasons it is recommended to configure Python virtual environment.
```python
virtualenv -p python3 directory_for_virtualenv

# Activate the virtual environment
source directory_for_virtualenv/bin/activate
```


### 2.1.3. Install using pip3 ###
* selenium

```
pip3 install selenium
```


### 2.1.4. Download and install manually ###
* geckodriver

Find latest release: <https://github.com/mozilla/geckodriver/releases/>


## 2.2. Example using apt in Ubuntu ##

```
sudo apt install python3 python3-pip virtualenv firefox
mkdir directory_for_virtualenv
virtualenv -p python3 directory_for_virtualenv
source directory_for_virtualenv/bin/activate
pip3 install selenium
wget https://github.com/mozilla/geckodriver/releases/SOMERELEASE
tar -fx geckodriver*.tar.gz –C directory_for_virtualenv/bin/
rm geckodriver*.tar.gz
```


## 2.3. Install on Debian/Ubuntu With `prep_weblogin` ##

If using a Linux distro with APT as packet manager, run the script
`prep_weblogin` to prepare the system for WebLogin.

| *Option* | *Value*       | *Default*   | *Comment*                      |
| ---------| ------------- | ------------| -------------------------------|
| `-d`     | PATH          | Current (.) | Installation directory         |
| `-f`     | VERSION       | Latest      | Version of Firefox             |
| `-g`     | URL           | Latest      | URL for geckodriver            |
| `-s`     | VERSION       | Latest      | Version of Selenium            |
| `-v`     | True\|False   | False       | Use Python virtual environment |

Return values:
|*Error* | *Description*                          |
| :----: | -------------------------------------- |
| 0      | Success!                               |
| 1      | Error                                  |
| 2      | Script must be run as root             |
| 3      | Script only works on Ubuntu and Debian |



## 2.4 Example ##
```
prep_weblogin -d /usr/local/bin/ \
              -f 59.0.2 \
              -s 3.11.0 \
              -g https://github.com/mozilla/geckodriver\
/releases/download/v0.20.1\
/geckodriver-v0.20.1-linux64.tar.gz
```


# 3. Compatibility Issues #
It is recommended to use the latest versions of Selenium, Firefox and 
GeckoDriver. However, in some Linux distributions, like Debian, the latest
version of packages may not be accessible in the standard repositories.

To get the latest versions in Debian, either download manually or
modify the sources.list file to allow downloads from the test or unstable
branches by changing the name of the version. The unstable branch is called
“Sid” and test has the name of the next version.

When an error occur it can be helpful to consult the log file for GeckoDriver, 
**geckodriver.log**. It will be generated where the script is executed from.

Error message that most likely means incompatibility:
```
selenium.common.exceptions.WebDriverException: Message: connection refused
```

The first step is to verify installed versions:
```
firefox –-version
pip3 show selenium
```


## 3.1. Install Firefox using non standard repositories ##
Modify the **sources.list** file to allow downloads from the test or unstable 
branches by changing the name of the version. The unstable branch is called 
“Sid” and test has the name of the next version.

| *Debian release* | *Year*     |
|------------------| ---------- |
| Buster           | 2018       |
| Stretch          | June 2017  |
| Jessie           | April 2015 |

Extract from **/etc/apt/sources.list** for Debian Stretch:
```
deb http://deb.debian.org/debian stretch main
deb-src http://deb.debian.org/debian stretch main

deb http://deb.debian.org/debian stretch-updates main
deb-src http://deb.debian.org/debian stretch-updates main

deb http://deb.debian.org/debian-secutirty stretch/updates main
deb-src http://deb.debian.org/debian-secutirty stretch/updates main
```


## 3.2. Install Firefox manually ##

Install dependencies on Debain/Ubuntu:
```
sudo apt install libgtk-3-0 libnss3 libvpx4 libdbus-glib-1-2 libxt6
```

Download and install latest version of Firefox:
```
wget 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US'
sudo tar jxf firefox*.tar.bz2 -C /usr/lib
sudo ln -s /usr/lib/firefox/firefox /usr/bin/firefox
```

Find latest relase: <https://ftp.mozilla.org/pub/firefox/releases/>


## 3.3. Choose version of Selenium to install ##
```
pip3 install selenium==[version]
```
