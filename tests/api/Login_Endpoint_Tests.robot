*** Settings ***
Documentation    Validate login endpoint.

Library          RequestsLibrary
Library          Collections
Resource         ${EXECDIR}/resources/api/Endpoints.resource
Resource         ${EXECDIR}/resources/api/Response_Utils.resource

Variables        ${EXECDIR}/configuration/locators.py

Suite Setup      Set Log Level    TRACE

*** Test Cases ***
Successful login through API using a valid credentials
    [Documentation]    Verify valid credentials can make successful request.
    [Tags]             smoke    api-login

    &{headers}     Create Dictionary    Content-Type=application/json
    
    &{payload}     Create Dictionary    email=${SETTINGS}[TEST_USER][USER_EMAIL]
    ...                                 password=${SETTINGS}[TEST_USER][USER_PASS]
    
    ${response}    POST    url=${login_endpoint}    json=${payload}    headers=${headers}

    Verify Response Status Code           response=${response}    expected_status_code=200
    Verify Response Reason                response=${response}    expected_reason=OK
    Verify Response Json Item             response=${response}    item_key=message    expected_item_value=Login realizado com sucesso
    Verify Response Json Contains Item    response=${response}    item_key=authorization

Unsuccessful login through API with invalid credential fields
    [Documentation]    Verify the application does NOT allow the user to login if any credential field is empty.
    [Tags]             smoke    api-login
    
    &{blank_fields_response}      Create Dictionary    email=email não pode ficar em branco
    ...                                                password=password não pode ficar em branco
    
    &{invalid_fields_response}    Create Dictionary    message=Email e/ou senha inválidos

    &{invalid_email_response}     Create Dictionary    email=email deve ser um email válido
    
    &{headers}     Create Dictionary    Content-Type=application/json
    
    # Both blank fields
    &{request_payload}     Create Dictionary    email=${EMPTY}
    ...                                         password=${EMPTY}
    
    ${expected_response_payload}    Set Variable    ${blank_fields_response}

    ${response}    POST    url=${login_endpoint}    json=${request_payload}    headers=${headers}    expected_status=400

    Verify Response Status Code    response=${response}    expected_status_code=400
    Verify Response Reason         response=${response}    expected_reason=Bad Request
    Verify Response Json Items     response=${response}    expected_items=${expected_response_payload}

    # Only email field empty
    &{request_payload}     Create Dictionary    email=${EMPTY}
    ...                                         password=12345
    
    ${expected_response_payload}    Set Variable    ${blank_fields_response}
    Remove From Dictionary    ${expected_response_payload}    password

    ${response}    POST    url=${login_endpoint}    json=${request_payload}    headers=${headers}    expected_status=400

    Verify Response Status Code    response=${response}    expected_status_code=400
    Verify Response Reason         response=${response}    expected_reason=Bad Request
    Verify Response Json Items     response=${response}    expected_items=${expected_response_payload}
    
    # Only password field empty
    &{request_payload}     Create Dictionary    email=test@email.com
    ...                                         password=${EMPTY}
    
    ${expected_response_payload}    Set Variable    ${blank_fields_response}
    Remove From Dictionary    ${expected_response_payload}    email

    ${response}    POST    url=${login_endpoint}    json=${request_payload}    headers=${headers}    expected_status=400

    Verify Response Status Code    response=${response}    expected_status_code=400
    Verify Response Reason         response=${response}    expected_reason=Bad Request
    Verify Response Json Items     response=${response}    expected_items=${expected_response_payload}
    
    # Invalid email format
    &{request_payload}     Create Dictionary    email=test@email
    ...                                         password=12345
    
    ${expected_response_payload}    Set Variable    ${invalid_email_response}
    
    ${response}    POST    url=${login_endpoint}    json=${request_payload}    headers=${headers}    expected_status=400

    Verify Response Status Code    response=${response}    expected_status_code=400
    Verify Response Reason         response=${response}    expected_reason=Bad Request
    Verify Response Json Items     response=${response}    expected_items=${expected_response_payload}
    
    # Invalid email
    &{request_payload}     Create Dictionary    email=not_a_real_user@email.com
    ...                                         password=12345
    
    ${expected_response_payload}    Set Variable    ${invalid_fields_response}
    
    ${response}    POST    url=${login_endpoint}    json=${request_payload}    headers=${headers}    expected_status=401

    Verify Response Status Code    response=${response}    expected_status_code=401
    Verify Response Reason         response=${response}    expected_reason=Unauthorized
    Verify Response Json Items     response=${response}    expected_items=${expected_response_payload}
