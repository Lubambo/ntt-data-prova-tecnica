*** Settings ***
Documentation    Create random entity instances to support test cases.

Library          SeleniumLibrary
Library          String
Library          Collections
Library          DateTime

*** Keywords ***
Create Entity Timestamp
    [Documentation]    Create a timestamp to be used on the entity properties.

    ${now}    Get Current Date
    ${now}    Replace String Using Regexp    string=${now}    pattern=\\s    replace_with=${EMPTY}
    ${now}    Replace String Using Regexp    string=${now}    pattern=:      replace_with=${EMPTY}
    ${now}    Replace String Using Regexp    string=${now}    pattern=-      replace_with=${EMPTY}
    ${now}    Replace String Using Regexp    string=${now}    pattern=\\.    replace_with=${EMPTY}

    RETURN    ${now}

Generate Random Product
    [Documentation]    Create a product with random properties values.
    [Arguments]        ${is_api_entity}=${false}
    
    ${now}    Create Entity Timestamp

    ${product_name}           Set Variable         New Product Name ${now}
    ${product_price}          Set Variable         ${{random.randint(0, 100)}}
    ${product_price}          Convert To String    ${product_price}
    ${product_description}    Set Variable         New Product Description ${now}
    ${product_quantity}       Set Variable         ${{random.randint(0, 100)}}
    ${product_quantity}       Convert To String    ${product_quantity}
    ${product_image}          Set Variable         ${EXECDIR}\\data\\test_image.png

    IF    '${is_api_entity}' == '${false}'
        &{product}    Create Dictionary    Nome=${product_name}
        ...                                Preço=${product_price}
        ...                                Descrição=${product_description}
        ...                                Quantidade=${product_quantity}
        ...                                Imagem=${product_image}
    ELSE
        &{product}    Create Dictionary    nome=${product_name}
        ...                                preco=${product_price}
        ...                                descricao=${product_description}
        ...                                quantidade=${product_quantity}
    END

    RETURN    ${product}

Generate Random User
    [Documentation]    Create an user with random properties values.
    [Arguments]        ${is_api_entity}=${false}
    
    ${now}    Create Entity Timestamp

    ${user_name}        Set Variable         New User Name ${now}
    ${user_email}       Set Variable         ${now}@email.com
    ${user_password}    Convert To String    ${{random.randint(10000, 100000)}}

    ${is_admin}         Set Variable         ${true}
    ${random_num}       Set Variable         ${{random.randint(0, 2)}}
    IF    ${random_num} == ${0}
        ${is_admin}    Set Variable    ${false}
   END

   ${is_admin}    Convert To String        ${is_admin}
   ${is_admin}    Convert To Lower Case    ${is_admin}

    IF    '${is_api_entity}' == '${false}'
        &{user}    Create Dictionary    Nome=${user_name}
        ...                             Email=${user_email}
        ...                             Senha=${user_password}
        ...                             Administrador=${is_admin}
    ELSE
        &{user}    Create Dictionary    nome=${user_name}
        ...                             email=${user_email}
        ...                             password=${user_password}
        ...                             administrador=${is_admin}
    END
    
    RETURN    ${user}