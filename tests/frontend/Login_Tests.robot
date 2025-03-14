*** Settings ***
Documentation    Validate login page

Resource         ${EXECDIR}/resources/pages/Login_Page.resource
Resource         ${EXECDIR}/resources/pages/Navigation_Header.resource

Suite Setup      Access Application

*** Variables ***

*** Test Cases ***
Successful login using a valid email and password
    [Documentation]    Verify user with valid credentials is able to access the application.
    [Tags]             smoke    login

    Log Into The Application    create_user_if_not_exists=${true}
    Logout The Application

Unsuccessful login with blank credential fields
    [Documentation]    Verify the application does NOT allow the user to login if any credential field is empty.
    [Tags]             login

    &{required_fields_alert}    Create Dictionary    email_alert=Email é obrigatório
    ...                                              pass_alert=Password é obrigatório
      
    # Both fields empty
    ${successful_login}    Run Keyword And Return Status    Log Into The Application    user_email=${EMPTY}    user_password=${EMPTY}
    IF    "${successful_login}" == "${true}"
        Fail    Allowed to login with empty credential fields!
    ELSE
        Wait Until Element Is Visible    locator=${login_page_alert_box}
        @{alert_elements}    Get WebElements    locator=${login_page_alert_msg}
        ${email_alert}       Get Text           locator=${alert_elements}[0]
        ${pass_alert}        Get Text           locator=${alert_elements}[1]

        Should Be Equal As Strings    ${required_fields_alert}[email_alert]    ${email_alert}
        Should Be Equal As Strings    ${required_fields_alert}[pass_alert]    ${pass_alert}

        FOR    ${element}    IN    @{alert_elements}
            Click Element    locator=${login_page_alert_btn}
        END
    END

    # Empty password field
    ${successful_login}    Run Keyword And Return Status    Log Into The Application    user_password=${EMPTY}
    IF    "${successful_login}" == "${true}"
        Fail    Allowed to login with empty password field!
    ELSE
        Wait Until Element Is Visible    locator=${login_page_alert_box}
        @{alert_elements}    Get WebElements    locator=${login_page_alert_msg}
        ${pass_alert}        Get Text           locator=${alert_elements}[0]

        Should Be Equal As Strings    ${required_fields_alert}[pass_alert]   ${pass_alert}
        Click Element    locator=${login_page_alert_btn}
    END

    # Empty email field
    Reload Page
    ${successful_login}    Run Keyword And Return Status    Log Into The Application    user_email=${EMPTY}
    IF    "${successful_login}" == "${true}"
        Fail    Allowed to login with empty email field!
    ELSE
        Wait Until Element Is Visible    locator=${login_page_alert_box}
        @{alert_elements}    Get WebElements    locator=${login_page_alert_msg}
        ${email_alert}       Get Text           locator=${alert_elements}[0]

        Should Be Equal As Strings    ${required_fields_alert}[email_alert]   ${email_alert}
        Click Element    locator=${login_page_alert_btn}
    END

Unsuccessful login with invalid credentials
    [Documentation]    Verify invalid credentials are not allowed to login.
    [Tags]             login

    ${bad_credentials_alert}         Set Variable    Email e/ou senha inválidos
    ${invalid_email_format_alert}    Set Variable    Email deve ser um email válido

    ${invalid_email}           Set Variable    invalid@email
    ${not_registered_email}    Set Variable    not.registered.user@email.com
    ${invalid_pass}            Set Variable    invalid_password

    # Not registered user 
    ${successful_login}    Run Keyword And Return Status    Log Into The Application    user_email=${not_registered_email}   user_password=${invalid_pass}
    IF    "${successful_login}" == "${true}"
        Fail    Allowed not registered user to login!
    ELSE
        Wait Until Element Is Visible    locator=${login_page_alert_box}
        @{alert_elements}    Get WebElements    locator=${login_page_alert_msg}
        ${alert}             Get Text           locator=${alert_elements}[0]

        Should Be Equal As Strings    ${bad_credentials_alert}   ${alert}
        Click Element    locator=${login_page_alert_btn}
    END

    # Invalid email
    ${successful_login}    Run Keyword And Return Status    Log Into The Application    user_email=${invalid_email}
    IF    "${successful_login}" == "${true}"
        Fail    Allowed not registered user to login!
    ELSE
        Wait Until Element Is Visible    locator=${login_page_alert_box}
        @{alert_elements}    Get WebElements    locator=${login_page_alert_msg}
        ${alert}             Get Text           locator=${alert_elements}[0]

        Should Be Equal As Strings    ${invalid_email_format_alert}   ${alert}
        Click Element    locator=${login_page_alert_btn}
    END

    # Invalid password
    ${successful_login}    Run Keyword And Return Status    Log Into The Application    user_password=${invalid_pass}
    IF    "${successful_login}" == "${true}"
        Fail    Allowed not registered user to login!
    ELSE
        Wait Until Element Is Visible    locator=${login_page_alert_box}
        @{alert_elements}    Get WebElements    locator=${login_page_alert_msg}
        ${alert}             Get Text           locator=${alert_elements}[0]

        Should Be Equal As Strings    ${bad_credentials_alert}   ${alert}
        Click Element    locator=${login_page_alert_btn}
    END
