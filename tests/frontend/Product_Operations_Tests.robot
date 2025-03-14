*** Settings ***
Documentation    Validate product related features.

Resource         ${EXECDIR}/resources/pages/Login_Page.resource
Resource         ${EXECDIR}/resources/pages/Register_Product_Page.resource
Resource         ${EXECDIR}/resources/pages/Products_List_Page.resource
Resource         ${EXECDIR}/resources/utils/Entity_Generator.resource

Suite Setup      Access Application And Login

*** Variables ***
&{random_product}    &{EMPTY}

*** Test Cases ***
Successful resgistration of a new product
    [Documentation]    Verify the application is able to register a new product.
    [Tags]             smoke    regression    product-operations

    Access Navigation Menu Item           item_title=${header_nav_bar_item_title_register_products}
    Check If Location Is Expected Page    page_title=${register_product_page_title}

    &{product}    Generate Random Product
    Set Suite Variable    &{random_product}    &{product}

    Register New Product    product_name=${product}[Nome]              product_price=${product}[Preço]    product_description=${product}[Descrição]    
    ...                     product_quantity=${product}[Quantidade]    product_image=${product}[Imagem]
    
    Check If Location Is Expected Page    page_title=${products_list_page_title}
    
    ${searched_product}    Find Product    header_cell_pair=${random_product}
    @{ignore_keys}    Create List    Imagem    Ações
    Dictionaries Should Be Equal    ${searched_product}    ${random_product}    ignore_keys=${ignore_keys}

Verify products list display values
    [Documentation]    Verify the products list is displaying values as expected.
    [Tags]             smoke    regression    product-operations
    
    Access Navigation Menu Item           item_title=${header_nav_bar_item_title_list_products}
    Check If Location Is Expected Page    page_title=${products_list_page_title}

    ${products_count}    Count Products

    IF    ${products_count} < ${1}
        Access Navigation Menu Item           item_title=${header_nav_bar_item_title_register_products}
        Check If Location Is Expected Page    page_title=${register_product_page_title}

        ${product}    Generate Random Product
        Set Suite Variable    &{random_product}    &{product}

        Register New Product    product_name=${product}[Nome]              product_price=${product}[Preço]    product_description=${product}[Descrição]    
        ...                     product_quantity=${product}[Quantidade]    product_image=${product}[Imagem]
        
        Check If Location Is Expected Page    page_title=${products_list_page_title}
    END
    
    @{products}    Get All Products    limit=${1}

    @{keys}    Get Dictionary Keys    ${products}[0]

    @{headers}    Create List    ${products_list_page_table_header_name}
    ...                          ${products_list_page_table_header_preco}
    ...                          ${products_list_page_table_header_description}
    ...                          ${products_list_page_table_header_quantity}
    ...                          ${products_list_page_table_header_image}
    
    ${keys_count}       Get Length    ${keys}
    ${headers_count}    Get Length    ${headers}
    Should Be Equal    ${headers_count}    ${keys_count}

    List Should Contain Sub List    ${headers}    ${keys}
    
Successful product removal
    [Documentation]    Verify that a product can be successfully deleted.
    [Tags]             smoke    regression    product-operations
    
    @{keys}          Get Dictionary Keys    ${random_product}
    ${keys_count}    Get Length             ${keys}

    IF    ${keys_count} < ${1}
        Access Navigation Menu Item           item_title=${header_nav_bar_item_title_register_products}
        Check If Location Is Expected Page    page_title=${register_product_page_title}

        &{product}    Generate Random Product
        Set Suite Variable    &{random_product}    &{product}

        Register New Product    product_name=${product}[Nome]              product_price=${product}[Preço]    product_description=${product}[Descrição]    
        ...                     product_quantity=${product}[Quantidade]    product_image=${product}[Imagem]
    ELSE
      Access Navigation Menu Item           item_title=${header_nav_bar_item_title_list_products}
      Check If Location Is Expected Page    page_title=${products_list_page_title}
    END
    
    Delete Product    header_cell_pair=${random_product}