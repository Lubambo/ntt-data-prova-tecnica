*** Settings ***
Documentation    Handle JSON operations.

Library          OperatingSystem
Library          jsonschema

*** Keywords ***
Load JSON Schema
    [Documentation]    Load JSON schema file and returns it as JSON that can be used like a dictionary.
    [Arguments]        ${json_schema_filepath}

    ${schema}    Get Binary File    ${json_schema_filepath}
    ${schema}    evaluate    json.loads('''${schema}''')    json

    RETURN    ${schema}

Validate JSON Schema
    [Documentation]   Verify if the given json instance is according to the expected json schema.
    [Arguments]        ${json_schema_filepath}    ${json_instance}
    
    ${schema}    Load JSON Schema    json_schema_filepath=${json_schema_filepath}
    ${json}      Evaluate    json.loads('''${json_instance}''')    json
    
    Validate    instance=${json}    schema=${schema}

Convert Dictionary Into JSON
    [Documentation]    Converts a dictionary into a JSON format.
    [Arguments]        ${dictionary_content}

    ${json}    Evaluate    json.dumps(${dictionary_content})    json
    RETURN    ${json}