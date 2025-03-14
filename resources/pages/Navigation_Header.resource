*** Settings ***
Documentation    Navigation header useful keywords.

Library          SeleniumLibrary
Library          String
Resource         Login_Page.resource

Variables        ${EXECDIR}/configuration/locators.py

*** Variables ***
${header_nav_bar_item}    //ul[contains(@class,'navbar')]//a[normalize-space(text())='ITEM_TITLE']
${header_logout_btn}      //button[@data-testid='logout']

${header_nav_bar_item_title_home}                 Home
${header_nav_bar_item_title_register_users}       Cadastrar Usuários
${header_nav_bar_item_title_list_users}           Listar Usuários
${header_nav_bar_item_title_register_products}    Cadastrar Produtos
${header_nav_bar_item_title_list_products}        Listar Produtos
${header_nav_bar_item_title_reports}              Relatórios

*** Keywords ***
Access Navigation Menu Item
    [Documentation]    Access the navigation menu item that has the given title.
    [Arguments]        ${item_title}

    ${item_locator}    Replace String Using Regexp    string=${header_nav_bar_item}    pattern=ITEM_TITLE    replace_with=${item_title}
    Wait Until Element Is Visible    locator=${item_locator}
    Click Element    locator=${item_locator}
Logout The Application
    [Documentation]    Log out the application.

    Click Element    locator=${header_logout_btn}
    Wait Until Page Contains Element    locator=${login_page_title}    timeout=${SETTINGS}[DEFAULT][TIMEOUT]
  