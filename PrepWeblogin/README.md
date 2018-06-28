## Install on Debian/Ubuntu With `prep_weblogin` ##

If using a Linux distro with APT as packet manager, run the script
`prep_weblogin` to prepare the system for WebLogin.

| *Option* | *Value*       | *Default*   | *Comment*                      |
| ---------| ------------- | ------------| -------------------------------|
| `-d`     | PATH          | Current (.) | Installation directory         |
| `-f`     | VERSION       | Latest      | Version of Firefox             |
| `-g`     | URL           | Latest      | URL for geckodriver            |
| `-s`     | VERSION       | Latest      | Version of Selenium            |
| `-v`     | True\|False   | False       | Use Python virtual environment |

Return values

|*Error* | *Description*                          |
| :----: | -------------------------------------- |
| 0      | Success!                               |
| 1      | Error                                  |
| 2      | Script must be run as root             |
| 3      | Script only works on Ubuntu and Debian |



## Example ##
```
prep_weblogin -d /usr/local/bin/ \
              -f 59.0.2 \
              -s 3.11.0 \
              -g https://github.com/mozilla/geckodriver\
/releases/download/v0.20.1\
/geckodriver-v0.20.1-linux64.tar.gz
```


# Compatibility Issues #
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
