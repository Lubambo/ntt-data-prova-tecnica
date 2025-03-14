*** Settings ***
Documentation    Handle Products endpoint operations.

Library          RequestsLibrary
Library          String
Library          Collections
Resource         ${EXECDIR}/resources/api/Endpoints.resource
Resource         ${EXECDIR}/resources/api/Response_Utils.resource
Resource         ${EXECDIR}/resources/utils/Json_Utils.resource

*** Keywords ***
Register New Product Through API
    [Documentation]    Create a new product via API.
    [Arguments]        ${name}    ${price}    ${description}    ${quantity}    
    ...                ${expected_status_code}=201    ${expected_reason}=Created
    ...                ${response_should_contain_product_id}=${true}
    ...                ${expected_payload_messages}=&{EMPTY}
    
    &{payload}     Create Dictionary    nome=${name}
    ...                                 preco=${price}
    ...                                 descricao=${description}
    ...                                 quantidade=${quantity}

    ${payload}    Convert Dictionary Into JSON    dictionary_content=${payload}
    
    ${response}    POST    url=${products_endpoint}    data=${payload}    headers=${default_headers}    expected_status=${expected_status_code}
    
    Verify Response Status Code           response=${response}    expected_status_code=${expected_status_code}
    Verify Response Reason                response=${response}    expected_reason=${expected_reason}

    FOR    ${key}    ${value}    IN    &{expected_payload_messages}
        Verify Response Json Item    response=${response}    item_key=${key}    expected_item_value=${value}
    END
    
    IF    '${response_should_contain_product_id}' == '${true}'
        Verify Response Json Contains Item    response=${response}    item_key=_id
    END

    RETURN    ${response}
    
Get Products Through API
    [Documentation]    Get products via API.
    [Arguments]        ${params}=&{EMPTY}    ${expected_payload_messages}=&{EMPTY}
    ...                ${expected_status_code}=200    ${expected_reason}=OK    ${expected_body_size}=${-1}

    ${response}    GET    url=${products_endpoint}    headers=${default_headers}    params=${params}    expected_status=${expected_status_code}
     
    Verify Response Status Code           response=${response}    expected_status_code=${expected_status_code}
    Verify Response Reason                response=${response}    expected_reason=${expected_reason}
    
    IF    ${expected_body_size} > ${-1}
        ${products}    Get From Dictionary    dictionary=${response.json()}   key=produtos    default=${none}
        ${products_count}    Get Length    ${products}
        Should Be Equal    ${products_count}    ${expected_body_size}
    END

    FOR    ${key}    ${value}    IN    &{expected_payload_messages}
        Verify Response Json Item    response=${response}    item_key=${key}    expected_item_value=${value}
    END
    
    RETURN    ${response}

Delete Product Through API
    [Documentation]    Delete the product that has the given id.
    [Arguments]        ${id}    ${expected_payload_messages}=&{EMPTY}

    ${url}    Catenate    SEPARATOR=${EMPTY}    ${products_endpoint}/    ${id}
    ${response}    DELETE    url=${url}    headers=${default_headers}

    FOR    ${key}    ${value}    IN    &{expected_payload_messages}
        Verify Response Json Item    response=${response}    item_key=${key}    expected_item_value=${value}
    END

    RETURN    ${response}
