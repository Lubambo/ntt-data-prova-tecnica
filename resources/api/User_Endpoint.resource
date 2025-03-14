*** Settings ***
Documentation    Handle Users endpoint operations.

Library          RequestsLibrary
Library          String
Library          Collections
Resource         ${EXECDIR}/resources/api/Endpoints.resource
Resource         ${EXECDIR}/resources/api/Response_Utils.resource
Resource         ${EXECDIR}/resources/utils/Json_Utils.resource

*** Keywords ***
Register New User Through API
    [Documentation]    Create a new user via API.
    [Arguments]        ${name}    ${email}    ${password}    ${administrator}    
    ...                ${expected_status_code}=201    ${expected_reason}=Created
    ...                ${response_should_contain_user_id}=${true}
    ...                ${expected_payload_messages}=&{EMPTY}
    
    &{payload}     Create Dictionary    nome=${name}
    ...                                 email=${email}
    ...                                 password=${password}
    ...                                 administrador=${administrator}

    ${payload}    Convert Dictionary Into JSON    dictionary_content=${payload}
    
    ${response}    POST    url=${users_endpoint}    data=${payload}    headers=${default_headers}    expected_status=${expected_status_code}
    
    Verify Response Status Code           response=${response}    expected_status_code=${expected_status_code}
    Verify Response Reason                response=${response}    expected_reason=${expected_reason}

    FOR    ${key}    ${value}    IN    &{expected_payload_messages}
        Verify Response Json Item    response=${response}    item_key=${key}    expected_item_value=${value}
    END
    
    IF    '${response_should_contain_user_id}' == '${true}'
        Verify Response Json Contains Item    response=${response}    item_key=_id
    END

    RETURN    ${response}
    
Get Users Through API
    [Documentation]    Get users via API.
    [Arguments]        ${params}=&{EMPTY}    ${expected_payload_messages}=&{EMPTY}
    ...                ${expected_status_code}=200    ${expected_reason}=OK    ${expected_body_size}=${-1}

    ${response}    GET    url=${users_endpoint}    headers=${default_headers}    params=${params}    expected_status=${expected_status_code}
     
    Verify Response Status Code           response=${response}    expected_status_code=${expected_status_code}
    Verify Response Reason                response=${response}    expected_reason=${expected_reason}
    
    IF    ${expected_body_size} > ${-1}
        ${users}    Get From Dictionary    dictionary=${response.json()}   key=usuarios    default=${none}
        ${users_count}    Get Length    ${users}
        Should Be Equal    ${users_count}    ${expected_body_size}
    END

    FOR    ${key}    ${value}    IN    &{expected_payload_messages}
        Verify Response Json Item    response=${response}    item_key=${key}    expected_item_value=${value}
    END
    
    RETURN    ${response}

Delete User Through API
    [Documentation]    Delete the user that has the given id.
    [Arguments]        ${id}    ${expected_payload_messages}=&{EMPTY}

    ${url}    Catenate    SEPARATOR=${EMPTY}    ${users_endpoint}/    ${id}
    ${response}    DELETE    url=${url}

    FOR    ${key}    ${value}    IN    &{expected_payload_messages}
        Verify Response Json Item    response=${response}    item_key=${key}    expected_item_value=${value}
    END

    RETURN    ${response}
