#!/usr/bin/python3
"""Script for testing accessability of a web site."""

import os
import sys
import shlex
import argparse
import time
import decimal

from selenium.webdriver import Firefox
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.ui import Select

# Create an ArgumentParser object
parser = argparse.ArgumentParser()

# Define what paremeters to use.
parser.add_argument('-a', '--url')
parser.add_argument('-c', '--config', 
                    dest='config', 
                    type=argparse.FileType(mode='r'))
parser.add_argument('-e', '--error_page', nargs=2)
parser.add_argument('-i', '--insert_test')
parser.add_argument('-l', '--login', nargs=2)
parser.add_argument('-v', '--verify', nargs=2)
parser.add_argument('-m', '--timer_max', type=int, default=35)
parser.add_argument('-n', '--timer_warning', type=int, default=7)
parser.add_argument('-o', '--timer_critical', type=int, default=15)
parser.add_argument('-p', '--password')
parser.add_argument('-s', '--login_sso', nargs=2)
parser.add_argument('-t', '--timeout', type=int, default=30)
parser.add_argument('-u', '--username')
parser.add_argument('-x', '--id_user')
parser.add_argument('-y', '--id_pass')

# Insert parameters to the class 'Namespace'.
args = parser.parse_args()

# Assign parameters to variables, vars(args) behaves as a dictionary.
url = vars(args)['url']
config = vars(args)['config']
error_page = vars(args)['error_page']
insert_test = vars(args)['insert_test']
login_button = vars(args)['login']
verify = vars(args)['verify']
timer_max = vars(args)['timer_max']
timer_warning = vars(args)['timer_warning']
timer_critical = vars(args)['timer_critical']
password = vars(args)['password']
login_sso = vars(args)['login_sso']
timeout = vars(args)['timeout']
username = vars(args)['username']
id_user = vars(args)['id_user']
id_pass = vars(args)['id_pass']

# Assign parameters from a config file to variables.
# !! Username and password not possible.
if args.config:
    args = parser.parse_args(shlex.split(args.config.read()))
    if not url:
        url = vars(args)['url']
    if not config:
        config = vars(args)['config']
    if not error_page:
        error_page = vars(args)['error_page']
    if not insert_test:
        insert_test = vars(args)['insert_test']
    if not login_button:
        login_button = vars(args)['login']
    if not verify:
        verify = vars(args)['verify']
    if not login_sso:
        login_sso = vars(args)['login_sso']
    if not timeout:
        timeout = vars(args)['timeout']
    if not id_user:
        id_user = vars(args)['id_user']
    if not id_pass:
        id_pass = vars(args)['id_pass']

# Split parameters where more than one choice is expected.
if error_page:
    error_page = (vars(args)['error_page'])[0]
    error_page_type = (vars(args)['error_page'])[1]
if login_button:
    login_button = (vars(args)['login'])[0]
    login_button_type = (vars(args)['login'])[1]
if verify:
    verify = (vars(args)['verify'])[0]
    verify_type = (vars(args)['verify'])[1]
if login_sso:
    login_sso = (vars(args)['login_sso'])[0]
    login_sso_type = (vars(args)['login_sso'])[1]

# Make Firefox use headless mode and geckodriver.
options = Options()
driver = Firefox(executable_path=\
         'geckodriver',\
         firefox_options=options)


def timer():
    # Set timer for login attempt.
    try:
        timestamp = open('timestamp.txt', 'w+')
        start_timer = str(time.time())
        timestamp.write(start_timer)
    except:
        mess = 'CRITICAL: Unable to set timer'
        exit_status(mess, 1)


def exit_status(message, value):
    """Calculate timer, write to logs and exit script."""
    # Calculate timer for login attempt.
    try:
        timestamp = open('timestamp.txt', 'r+')
        timestamp_float = float(timestamp.read())
        total = round((time.time() - timestamp_float))
        timestamp.close()
        message_output=(message + ' | Time=%d;%d;%d' % \
                       (total, timer_warning, timer_critical))
        print(message_output)
        driver.quit()
    except:
        print('Unable to read timer')
        driver.quit()


def begin_login():
    """Go to URL."""
    try:
        driver.get(url)
    except:
        exit_status('CRITICAL: URL not working', 1)


def test_errorpage():
    """Check if redirected to known error page."""
    driver.implicitly_wait(timeout)
    if error_page:
        mess = 'WARNING: Redirected to sorry page'
        try:
            if error_page_type == 'title':
                if driver.title == error_page:
                    sys.exit(1)
            elif error_page_type == 'h1':
                header = driver.find_element_by_tag_name(error_page_type)
                if header.text == error_page:
                    sys.exit(1)
            elif error_page_type == 'h2':
                header = driver.find_element_by_tag_name(error_page_type)
                if header.text == error_page:
                    sys.exit(1)
            else:
                mess = 'CRITICAL: Wrong type for option --error_page'
                sys.exit(1)
        except:
            exit_status(mess, 1)
        

def page_login_sso():
    """Find login button to get redirected for login to SSO if required."""
    mess = ''
    if login_sso:
        try:
            # Log in on SSO based on type.
            if login_sso_type == 'name':
                driver.find_element_by_name(login_sso).click()
            elif login_sso_type == 'link':
                driver.find_element_by_partial_link_text(login_sso).click()
            else:
                mess = ', wrong type for option --login_sso'
                sys.exit(1)
        except:
            exit_status('CRITICAL: Unable to locate login button' + mess, 2)


def page_login():
    """Submit username and password and click login."""
    mess = ''
    try:
        # Fill login forms with username and password.
        driver.implicitly_wait(timeout)
        driver.find_element_by_id(id_user).clear()
        driver.find_element_by_id(id_user).send_keys(username)
        driver.find_element_by_id(id_pass).clear()
        driver.find_element_by_id(id_pass).send_keys(password)
        # Click on login button based on type.
        if login_button_type == 'id':
            driver.find_element_by_id(login_button).click()
        elif login_button_type == 'name':
            driver.find_element_by_name(login_button).click()
        elif login_button_type == 'link':
            driver.find_element_by_partial_link_text(login_button).click()
        else:
            mess = ', wrong type for option --login'
            sys.exit(1)
    except:
        #exit_status('CRITICAL: Unable to login' + mess, 2)
        print('hej')


def custom_test():
    """Insert additional tests from file."""
    try:
        if os.path.exists(insert_test):
            exec(open(insert_test).read())
    except:
        return


def page_login_verify():
    """Verify login by identifying logout button"""
    mess = ''
    try:
        if verify_type == 'name':
            v = driver.find_element_by_name(verify)
        elif verify_type == 'link':
            v = driver.find_element_by_partial_link_text(verify)
        elif verify_type == 'class':
            v = driver.find_element_by_class_name(verify)
        else:
            mess = ', wrong type for option --verify'
            sys.exit(1)
    except:
        exit_status('CRITICAL: Unable to verify login' +  mess, 2)
    exit_status('OK: Login successful', 0)


def main():
    timer()
    begin_login()
    test_errorpage()
    page_login_sso()
    page_login()
    custom_test()
    page_login_verify()


if __name__ == "__main__":
    main()
