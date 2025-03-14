*** Settings ***
Documentation    Validate product endpoint.

Library          RequestsLibrary
Library          Collections
Resource         ${EXECDIR}/resources/utils/Entity_Generator.resource
Resource         ${EXECDIR}/resources/api/Product_Endpoint.resource
Resource         ${EXECDIR}/resources/api/Utils.resource

Variables        ${EXECDIR}/configuration/locators.py

Suite Setup      Get Auth Token

*** Variables ***
&{random_product}    &{EMPTY}

*** Test Cases ***
Product registration successfully completed through API
    [Documentation]    Verify valid credentials can make successful registration.
    [Tags]             smoke    api-product
    
    &{product}    Generate Random Product    is_api_entity=${true}
    &{payload}    Set Variable    ${product}

    &{expected_messages}    Create Dictionary    message=Cadastro realizado com sucesso

    ${response}    Register New Product Through API    name=${payload}[nome]    price=${payload}[preco]    description=${payload}[descricao]    quantity=${payload}[quantidade]
    ...                                                expected_payload_messages=${expected_messages}

    ${id}    Get From Dictionary    dictionary=${response.json()}    key=_id    default=${none}
    Set To Dictionary    ${product}    id=${id}
    Set Suite Variable    &{random_product}    &{product}

Attempt to register product with invalid credentials through API
    [Documentation]    Verify if the API block the product registration if any credential is invalid.
    [Tags]             smoke    api-product

    Set Up Product Entity Suite Variable
    &{payload}    Set Variable    ${random_product}
    Remove From Dictionary    ${payload}    id

    # Empty values
    &{expected_messages}    Create Dictionary    nome=nome não pode ficar em branco
	...                                          preco=preco deve ser um número positivo
	...                                          descricao=descricao não pode ficar em branco
    
    Register New Product Through API    name=${EMPTY}    price=${0}    description=${EMPTY}    quantity=${0}
    ...                                 expected_status_code=400    expected_reason=Bad Request    response_should_contain_product_id=${false}
    ...                                 expected_payload_messages=${expected_messages}
    
    # Duplicate name
    &{expected_messages}    Create Dictionary    message=Já existe produto com esse nome
    
    Register New Product Through API    name=${payload}[nome]    price=${payload}[preco]    description=${payload}[descricao]    quantity=${payload}[quantidade]
    ...                                 expected_status_code=400    expected_reason=Bad Request    response_should_contain_product_id=${false}
    ...                                 expected_payload_messages=${expected_messages}

Successfully Get Products
    [Documentation]    Verify valid credentials can make successful request.
    [Tags]             smoke    api-product

    Set Up Product Entity Suite Variable
    &{payload}    Set Variable    ${random_product}
    Remove From Dictionary    ${payload}    id

    # Get all products
    ${response}    Get Products Through API
    
    # Get single product
    ${response}    Get Products Through API    params=${payload}    expected_body_size=${1}

Successfully Delete Products
    [Documentation]    Verify valid credentials can make successful request.
    [Tags]             smoke    api-product

    Set Up Product Entity Suite Variable

    &{expected_messages}    Create Dictionary    message=Registro excluído com sucesso
    Delete Product Through API    id=${random_product}[id]    expected_payload_messages=${expected_messages}
    
    &{expected_messages}    Create Dictionary    message=Nenhum registro excluído
    Delete Product Through API    id=${random_product}[id]    expected_payload_messages=${expected_messages}

*** Keywords ***
Set Up Product Entity Suite Variable
    [Documentation]    If there is no value on the random_product suite variable, it will add one and create a register on the application using the random_product values.

    @{keys}          Get Dictionary Keys    ${random_product}
    ${keys_count}    Get Length             ${keys}

    IF    ${keys_count} < ${1}
        &{product}        Generate Random Product             is_api_entity=${true}
        ${response}    Register New Product Through API    name=${product}[nome]    price=${product}[preco]    description=${product}[descricao]    quantity=${product}[quantidade]
        ${id}          Get From Dictionary    dictionary=${response.json()}    key=_id    default=${none}
        Set To Dictionary    ${product}    id=${id}
        Set Suite Variable    &{random_product}    &{product}
    END

Get Auth Token
    [Documentation]    Product endpoints require authorization token, due to that, it is necessary to login into the application and get the token on local storage.

    Set Log Level    TRACE
    ${token}    Get User Authorization Token
    Set Suite Variable    ${auth_token}    ${token}
    Set To Dictionary    ${default_headers}    Authorization=${auth_token}