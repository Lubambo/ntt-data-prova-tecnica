*** Settings ***
Documentation    Login page useful keywords.

Library          SeleniumLibrary
Resource         Navigation_Header.resource

Variables        ${EXECDIR}/configuration/locators.py

*** Variables ***
# User registration form
${user_registration_form_username}             //input[@data-testid='nome']
${user_registration_form_email}                //input[@data-testid='email']
${user_registration_form_password}             //input[@data-testid='password']
${user_registration_form_is_admin_checkbox}    //input[@name='administrador']
${user_registration_form_resgister_btn}        //button[@data-testid='cadastrar']

# Login form
${login_page_title}             //h1[normalize-space(text())='Login']
${login_page_email_input}       //input[@id='email']
${login_page_password_input}    //input[@id='password']
${login_page_submit_btn}        //button[@type='submit']
${login_page_register_link}     //a[@type='button']

# Alert message
${login_page_alert_box}    //div[@role='alert']
${login_page_alert_msg}    ${login_page_alert_box}/span
${login_page_alert_btn}    ${login_page_alert_box}/button

*** Keywords ***
Access Application
    [Documentation]    Access the application on the given url and browser. By default it will access the base url on chrome browser.
    [Arguments]        ${url}=${SETTINGS}[DEFAULT][BASE_URL]    ${browser}=${SETTINGS}[DEFAULT][BROWSER]

    Set Log Level    TRACE
    Open Browser     url=${url}    browser=${browser}
    Maximize Browser Window

Sign Up New User
    [Documentation]    Register a new user on the application. By default, it will register the user as administrator, set is_admin_user as False to register regular user.
    [Arguments]        ${username}=${SETTINGS}[TEST_USER][USER_NAME]    ${user_email}=${SETTINGS}[TEST_USER][USER_EMAIL]    ${user_password}=${SETTINGS}[TEST_USER][USER_PASS]    ${is_admin_user}=${true}

    Clear Element Text    locator=${user_registration_form_username}
    Clear Element Text    locator=${user_registration_form_email}
    Clear Element Text    locator=${user_registration_form_password}

    Input Text    locator=${user_registration_form_username}   text=${username}
    Input Text    locator=${user_registration_form_email}      text=${user_email}
    Input Text    locator=${user_registration_form_password}   text=${user_password}

    IF    ${is_admin_user}
        Click Element    locator=${user_registration_form_is_admin_checkbox}
    END

    Click Element    locator=${user_registration_form_resgister_btn}

Log Into The Application
    [Documentation]    Log into the application using the given user's credentials.
    [Arguments]        ${user_email}=${SETTINGS}[TEST_USER][USER_EMAIL]    ${user_password}=${SETTINGS}[TEST_USER][USER_PASS]    ${create_user_if_not_exists}=${false}

    Clear Element Text    locator=${login_page_email_input}
    Clear Element Text    locator=${login_page_password_input}

    Input Text       locator=${login_page_email_input}      text=${user_email}
    Input Text       locator=${login_page_password_input}   text=${user_password}

    Click Element    locator=${login_page_submit_btn}

    ${successful_login}    Run Keyword And Return Status    Wait Until Page Contains Element    locator=${header_logout_btn}    timeout=${SETTINGS}[DEFAULT][TIMEOUT]

    IF    "${create_user_if_not_exists}" == "${true}"
        IF    "${successful_login}" == "${false}"
            Click Element    locator=${login_page_register_link}
            Sign Up New User
            Wait Until Page Contains Element    locator=${header_logout_btn}    timeout=${SETTINGS}[DEFAULT][TIMEOUT]
        END
    ELSE IF    "${create_user_if_not_exists}" == "${false}" and "${successful_login}" == "${false}"
        Wait Until Element Is Visible    locator=${login_page_alert_box}
        ${alert_element}    Get WebElement    locator=${login_page_alert_msg}
        ${alert_msg}        Get Text          locator=${alert_element}

        Capture Page Screenshot
        FAIL    ${alert_msg}
    END

Access Application And Login
    [Documentation]    Access the application on the given url and browser. By default it will access the base url on chrome browser. Then login using the given user's credentials.
    [Arguments]        ${url}=${SETTINGS}[DEFAULT][BASE_URL]    ${browser}=${SETTINGS}[DEFAULT][BROWSER]
    ...                ${user_email}=${SETTINGS}[TEST_USER][USER_EMAIL]    ${user_password}=${SETTINGS}[TEST_USER][USER_PASS]
    ...                ${create_user_if_not_exists}=${false}
    
    Access Application          url=${url}    browser=${browser}
    Log Into The Application    user_email=${user_email}    user_password=${user_password}    create_user_if_not_exists=${create_user_if_not_exists}

    
