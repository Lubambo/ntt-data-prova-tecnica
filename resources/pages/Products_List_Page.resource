*** Settings ***
Documentation    Products list page useful keywords.

Library          SeleniumLibrary
Library          String
Resource         Common_Page.resource
Resource         Register_Product_Page.resource
Resource         ${EXECDIR}/resources/utils/Table_Handler.resource

*** Variables ***
${products_list_page_title}    Lista dos Produtos

${products_list_page_table_header_name}           Nome
${products_list_page_table_header_preco}          Preço
${products_list_page_table_header_description}    Descrição
${products_list_page_table_header_quantity}       Quantidade
${products_list_page_table_header_image}          Imagem
${products_list_page_table_header_action}         Ação

*** Keywords ***
Count Products
    [Documentation]    Return the number of products on the table.

    ${products_count}    Get Table Rows Count    table_locator=${common_page_table}
    RETURN    ${products_count}

Get All Products
    [Documentation]    Return all items in the products table.
    [Arguments]        ${limit}=${-1}    ${return_as_webelement}=${false}

    @{headers}    Create List    ${products_list_page_table_header_name}
    ...                          ${products_list_page_table_header_preco}
    ...                          ${products_list_page_table_header_description}
    ...                          ${products_list_page_table_header_quantity}
    ...                          ${products_list_page_table_header_image}
    
    IF    '${return_as_webelement}' == '${true}'
        Append To List    ${headers}    ${products_list_page_table_header_action}
    END
       
    @{products}    Get All Table Rows    table_locator=${common_page_table}    headers=${headers}    limit=${limit}    return_as_webelement=${return_as_webelement}

    RETURN    ${products}
  
Find Product
    [Documentation]    Find the first product in the table that has the headers containing the respective cell values.
    [Arguments]        ${header_cell_pair}    ${return_as_webelement}=${false}

    &{row}    Find Table Record    header_cell_pair=${header_cell_pair}    return_as_webelement=${return_as_webelement}
    RETURN    ${row}

Edit Product
    [Documentation]    Edit a product in the products table. If no header_cell_pair value is given, in order to search a respective product, it will edit the first product in the table.
    [Arguments]        ${product_name}    ${product_price}    ${product_description}    ${product_quantity}    ${product_image}    ${header_cell_pair}=&{EMPTY}

    Access Table Record Edit Action    header_cell_pair=${header_cell_pair}

    Register New Product    product_name=${product_name}    product_price=${product_price}    product_description=${product_description}    
    ...                     product_quantity=${product_quantity}    product_image=${product_image}

Delete Product
    [Documentation]    Delete a product in the products table. If no header_cell_pair value is given, in order to search a respective product, it will delete the first product in the table.
    [Arguments]        ${header_cell_pair}=&{EMPTY}
    
    ${deleted_record}    Delete Table Record    header_cell_pair=${header_cell_pair}

    ${searched_item}    Find Product    header_cell_pair=${deleted_record}
    Should Be Equal    '${searched_item}'    '&{EMPTY}'