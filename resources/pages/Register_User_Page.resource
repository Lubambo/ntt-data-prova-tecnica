*** Settings ***
Documentation    Register user page useful keywords.

Library          SeleniumLibrary
Library          String
Resource         Common_Page.resource

*** Variables ***
${register_user_page_title}    Cadastro de usuários

${register_user_page_input_label_name}                Nome: *
${register_user_page_input_label_email}               Email: *
${register_user_page_input_label_password}            Senha: *
${register_user_page_input_label_is_administrator}    Cadastrar como administrador?

*** Keywords ***
Register New User
    [Documentation]    Set values in the user registration form then click on the submit button.
    [Arguments]        ${user_name}    ${user_email}    ${user_password}    ${user_is_administrator}

    Set Value To Registration Page Input    input_label=${register_user_page_input_label_name}                input_value=${user_name}
    Set Value To Registration Page Input    input_label=${register_user_page_input_label_email}               input_value=${user_email}
    Set Value To Registration Page Input    input_label=${register_user_page_input_label_password}            input_value=${user_password}
    Set Value To Registration Page Input    input_label=${register_user_page_input_label_is_administrator}    input_value=${user_is_administrator}
    
    Click Element    locator=${common_page_registration_submit_btn}

