*** Settings ***
Documentation    Register product page useful keywords.

Library          SeleniumLibrary
Library          String
Resource         Common_Page.resource

*** Variables ***
${register_product_page_title}    Cadastro de Produtos

${register_product_page_input_label_name}           Nome: *
${register_product_page_input_label_preco}          Preço: *
${register_product_page_input_label_description}    Descrição: *
${register_product_page_input_label_quantity}       Quantidade: *
${register_product_page_input_label_image}          Imagem: *

*** Keywords ***
Register New Product
    [Documentation]    Set values in the product registration form then click on the submit button.
    [Arguments]        ${product_name}    ${product_price}    ${product_description}    ${product_quantity}    ${product_image}

    Set Value To Registration Page Input    input_label=${register_product_page_input_label_name}           input_value=${product_name}
    Set Value To Registration Page Input    input_label=${register_product_page_input_label_preco}          input_value=${product_price}
    Set Value To Registration Page Input    input_label=${register_product_page_input_label_description}    input_value=${product_description}
    Set Value To Registration Page Input    input_label=${register_product_page_input_label_quantity}       input_value=${product_quantity}
    Set Value To Registration Page Input    input_label=${register_product_page_input_label_image}          input_value=${product_image}
    
    Click Element    locator=${common_page_registration_submit_btn}

