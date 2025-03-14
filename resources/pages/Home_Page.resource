*** Settings ***
Documentation    Home page useful keywords.

Library          SeleniumLibrary
Library          String

*** Variables ***
${home_page_title}    Bem Vindo USER_NAME

${home_page_card_container}    //div[@class='card-body' and ./h5[normalize-space(text())='CARD_TITLE']]
${home_page_card_btn}          ${home_page_card_container}/a

${home_page_card_title_register_users}       Cadastrar Usuários
${home_page_card_title_list_users}           Listar Usuários
${home_page_card_title_register_products}    Cadastrar Produtos
${home_page_card_title_list_products}        Listar Produtos
${home_page_card_title_reports}              Relatórios

*** Keywords ***
Access Operation Card
    [Documentation]    Click on the access button of the card that has the given card title.
    [Arguments]        ${card_title}

    ${btn_locator}    Replace String Using Regexp    string=${home_page_card_btn}    pattern=CARD_TITLE    replace_with=${card_title}
    Wait Until Element Is Visible    locator=${btn_locator}
    Click Element    locator=${btn_locator}