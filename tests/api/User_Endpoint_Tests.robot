*** Settings ***
Documentation    Validate user endpoint.

Library          RequestsLibrary
Library          Collections
Resource         ${EXECDIR}/resources/utils/Entity_Generator.resource
Resource         ${EXECDIR}/resources/api/User_Endpoint.resource

Variables        ${EXECDIR}/configuration/locators.py

Suite Setup      Set Log Level    TRACE

*** Variables ***
&{random_user}    &{EMPTY}

*** Test Cases ***
User registration successfully completed through API
    [Documentation]    Verify valid credentials can make successful registration.
    [Tags]             smoke    api-user
    
    &{user}    Generate Random User    is_api_entity=${true}
    &{payload}    Set Variable    ${user}

    &{expected_messages}    Create Dictionary    message=Cadastro realizado com sucesso

    ${response}    Register New User Through API    name=${payload}[nome]    email=${payload}[email]    password=${payload}[password]    administrator=${payload}[administrador]
    ...                                             expected_payload_messages=${expected_messages}
    
    ${id}    Get From Dictionary    dictionary=${response.json()}    key=_id    default=${none}
    Set To Dictionary    ${user}    id=${id}
    Set Suite Variable    &{random_user}    &{user}

Attempt to register user with invalid credentials through API
    [Documentation]    Verify if the API block the user registration if any credential is invalid.
    [Tags]             smoke    api-user

    Set Up User Entity Suite Variable
    &{payload}    Set Variable    ${random_user}
    Remove From Dictionary    ${payload}    id

    # Empty values
    &{expected_messages}    Create Dictionary    nome=nome não pode ficar em branco
	...                                          email=email não pode ficar em branco
	...                                          password=password não pode ficar em branco
	...                                          administrador=administrador deve ser 'true' ou 'false'
    
    Register New User Through API    name=${EMPTY}    email=${EMPTY}    password=${EMPTY}    administrator=${EMPTY}
    ...                              expected_status_code=400    expected_reason=Bad Request    response_should_contain_user_id=${false}
    ...                              expected_payload_messages=${expected_messages}
    
    # Duplicate email
    &{expected_messages}    Create Dictionary    message=Este email já está sendo usado
    
    Register New User Through API    name=${payload}[nome]    email=${payload}[email]    password=${payload}[password]    administrator=${payload}[administrador]
    ...                              expected_status_code=400    expected_reason=Bad Request    response_should_contain_user_id=${false}
    ...                              expected_payload_messages=${expected_messages}

    # Invalid email format
    &{expected_messages}    Create Dictionary    email=email deve ser um email válido
    
    Register New User Through API    name=${payload}[nome]    email=invalid.format@email    password=${payload}[password]    administrator=${payload}[administrador]
    ...                              expected_status_code=400    expected_reason=Bad Request    response_should_contain_user_id=${false}
    ...                              expected_payload_messages=${expected_messages}

Successfully Get Users
    [Documentation]    Verify valid credentials can make successful request.
    [Tags]             smoke    api-user

    Set Up User Entity Suite Variable
    &{payload}    Set Variable    ${random_user}
    Remove From Dictionary    ${payload}    id

    # Get all users
    ${response}    Get Users Through API
    
    # Get single user
    ${response}    Get Users Through API    params=${payload}    expected_body_size=${1}

Successfully Delete Users
    [Documentation]    Verify valid credentials can make successful request.
    [Tags]             smoke    api-user

    Set Up User Entity Suite Variable

    # Successfully deleted
    &{expected_messages}    Create Dictionary    message=Registro excluído com sucesso
    Delete User Through API    id=${random_user}[id]    expected_payload_messages=${expected_messages}
    
    # No item to be deleted
    &{expected_messages}    Create Dictionary    message=Nenhum registro excluído
    Delete User Through API    id=${random_user}[id]    expected_payload_messages=${expected_messages}

*** Keywords ***
Set Up User Entity Suite Variable
    [Documentation]    If there is no value on the random_user suite variable, it will add one and create a register on the application using the random_user values.

    @{keys}          Get Dictionary Keys    ${random_user}
    ${keys_count}    Get Length             ${keys}

    IF    ${keys_count} < ${1}
        &{user}        Generate Random User             is_api_entity=${true}
        ${response}    Register New User Through API    name=${user}[nome]    email=${user}[email]    password=${user}[password]    administrator=${user}[administrador]
        ${id}          Get From Dictionary    dictionary=${response.json()}    key=_id    default=${none}
        Set To Dictionary    ${user}    id=${id}
        Set Suite Variable    &{random_user}    &{user}
    END