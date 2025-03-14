*** Settings ***
Documentation    Useful keywords to handle response valdiations.

Library          String
Library          Collections
Resource         ${EXECDIR}/resources/utils/Json_Utils.resource

*** Keywords ***
Verify Response Status Code
    [Documentation]    Verify if the response status code is equals to the expected one.
    [Arguments]        ${response}    ${expected_status_code}

    Should Be Equal As Strings    ${response.status_code}    ${expectedStatusCode}

Verify Response Reason
    [Documentation]    Verify if the response reason is equals to the expected one.
    [Arguments]        ${response}    ${expected_reason}

    ${actual_reason}      Convert To Lower Case    ${response.reason}
    ${expected_reason}    Convert To Lower Case    ${expected_reason}

    Should Be Equal As Strings    ${actual_reason}    ${expected_reason}

Verify Response Header
    [Documentation]    Verify if the response header that has the given title has its value quals to the expected one.
    [Arguments]        ${response}    ${header_title}    ${expected_value}

    Dictionary Should Contain Item    ${response.headers}    ${header_title}    ${expected_value}

Verify Response Json Schema
    [Documentation]    Verify if the response JSON has the expected schema.
    [Arguments]        ${response}    ${schema_file}
    
    Validate JSON Schema    json_schema_filepath=${schema_file}    json_instance=${response.json()}

Verify Response Json Item
    [Documentation]    Verify if the response JSON has the expected schema.
    [Arguments]        ${response}    ${item_key}    ${expected_item_value}
    
    Dictionary Should Contain Item    ${response.json()}    ${item_key}    ${expected_item_value}
  
Verify Response Json Items
    [Documentation]    Verify if the response JSON has the expected schema.
    [Arguments]        ${response}    ${expected_items}

    Dictionary Should Contain Sub Dictionary    ${response.json()}    ${expected_items}

Verify Response Json Contains Item
    [Documentation]    Verify if the response JSON has the expected schema.
    [Arguments]        ${response}    ${item_key}
    
    ${json}    Set Variable    ${response.json()}
    Dictionary Should Contain Key    dictionary=${json}    key=${item_key}
    ${item_value}    Get From Dictionary    dictionary=${json}    key=${item_key}    default=${none}
    ${item_value_length}    Get Length    ${item_value}
    Should Be True    ${item_value_length} > ${0}
