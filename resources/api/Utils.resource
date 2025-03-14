*** Settings ***
Documentation    Useful keywords to handle API.

Resource         ${EXECDIR}/resources/pages/Login_Page.resource

Variables        ${EXECDIR}/configuration/locators.py

*** Keywords ***
Get User Authorization Token
    [Documentation]    Log into the application to retrieve access token on local storage.
    [Arguments]        ${user_email}=${SETTINGS}[TEST_USER][USER_EMAIL]    ${user_password}=${SETTINGS}[TEST_USER][USER_PASS]

    Access Application And Login    user_email=${user_email}    user_password=${user_password}    create_user_if_not_exists=${true}
    ${auth_token}    Execute Javascript    return window.localStorage.getItem("serverest/userToken")
    Close Browser

    RETURN    ${auth_token}