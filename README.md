# WebLogin #
Script for testing accessibility of a web site using Selenium and Firefox.

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

### 2.1. Needed packages ###
* python3
* python3-pip
* firefox (firefox-esr)
* virtualenv
* selenium (install using pip)

### 2.2 Download and install manually ###
* geckodriver

Find latest release: <https://github.com/mozilla/geckodriver/releases/>


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
