*** Settings ***
Documentation    Home page useful keywords.

Library          SeleniumLibrary
Library          String
Library          Collections
Resource         ${EXECDIR}/resources/utils/Table_Handler.resource

Variables        ${EXECDIR}/configuration/locators.py

*** Variables ***
${common_page_header_title}    //h1

# Registration form
${common_page_registration_input}         //*[(local-name()='input' or local-name()='textarea') and (./preceding-sibling::label[normalize-space(text())='INPUT_LABEL'] or ./following-sibling::label[normalize-space(text())='INPUT_LABEL'])]
${common_page_registration_submit_btn}    //button[@type='submit']

# Table list
${common_page_table}    //p/table

*** Keywords ***
Get Page Header Title
    [Documentation]    Get page title.

    ${page_title}    Get Element Attribute    locator=${common_page_header_title}    attribute=innerHTML

Check If Location Is Expected Page
    [Documentation]    Verify if the current page is the expected one.
    [Arguments]        ${page_title}    ${stop_on_failure}=${true}    ${timeout}=${SETTINGS}[DEFAULT][TIMEOUT]

    ${current_page_title}    Catenate    SEPARATOR=${EMPTY}    ${common_page_header_title}    [normalize-space(text())='${page_title}']
    Wait Until Element Is Visible    locator=${current_page_title}    timeout=${timeout}

    ${is_visible}    Run Keyword And Return Status    Element Should Be Visible    locator=${current_page_title}

    IF    '${stop_on_failure}' == '${true}' and '${is_visible}' == '${false}'
        Fail    Page title not visible!
    END

    RETURN    ${is_visible}

Set Value To Registration Page Input
    [Documentation]    Set value to the input that has the given label.
    [Arguments]        ${input_label}    ${input_value}

    ${input_locator}    Replace String Using Regexp    string=${common_page_registration_input}    pattern=INPUT_LABEL    replace_with=${input_label}
    ${input_type}       Get Element Attribute    locator=${input_locator}    attribute=type

    IF    '${input_type}' == 'file'
        Choose File    locator=${input_locator}    file_path=${input_value}
    ELSE IF    '${input_type}' == 'checkbox'
        ${is_checked}    Run Keyword And Return Status    Checkbox Should Be Selected    locator=${input_locator}

        IF    '${is_checked}' == '${true}' and ('${input_value}' == '${false}' or '${input_value}' == 'false')
            Click Element    locator=${input_locator}
        ELSE IF    '${is_checked}' == '${false}' and ('${input_value}' == '${true}' or '${input_value}' == 'true')
            Click Element    locator=${input_locator}
        END
    ELSE
        Input Text    locator=${input_locator}    text=${input_value}
    END

Find Table Record
    [Documentation]    Find the first record in the table that has the headers containing the respective cell values.
    [Arguments]        ${header_cell_pair}    ${return_as_webelement}=${false}

    Remove From Dictionary    ${header_cell_pair}    Imagem
    &{row}    Find Table Row    table_locator=${common_page_table}    header_cell_pair=${header_cell_pair}    return_as_webelement=${return_as_webelement}
    Remove From Dictionary    ${row}    Ações

    RETURN    ${row}

Access Table Record Edit Action
    [Documentation]    Access edit action of a record in the table. If no header_cell_pair value is given, in order to search a respective record, it will edit the first record in the table.
    [Arguments]        ${header_cell_pair}=&{EMPTY}

    @{keys}          Get Dictionary Keys    dictionary=${header_cell_pair}
    ${keys_count}    Get Length             ${keys}

    IF    ${keys_count} > ${0}
        ${row}    Find Table Row    table_locator=${common_page_table}    header_cell_pair=${header_cell_pair}
    ELSE
        ${row}    Get Table Row     table_locator=${common_page_table}    row_index=1
    END

    Click Element    locator=${row}[Ações][Editar]

Delete Table Record
    [Documentation]    Delete a record in the table. If no header_cell_pair value is given, in order to search a respective record, it will delete the first record in the table.
    ...                It returns the deleted record values as a dictionary, in which the keys are the headers and the values are the respective cell value.
    [Arguments]        ${header_cell_pair}=&{EMPTY}

    @{keys}          Get Dictionary Keys    dictionary=${header_cell_pair}
    ${keys_count}    Get Length             ${keys}

    ${row}    Set Variable    ${EMPTY}

    IF    ${keys_count} > ${0}
        ${row}    Find Table Row    table_locator=${common_page_table}    header_cell_pair=${header_cell_pair}
    ELSE
        ${row}    Get Table Row     table_locator=${common_page_table}    row_index=1
    END

    &{row_header_cell_pair}    Create Dictionary    &{EMPTY}
    FOR    ${key}    ${value}    IN    &{row}
        IF    '${key}' != 'Imagem' and '${key}' != 'Ações'
            ${value_text}    Get Text    locator=${value}
            Set To Dictionary    ${row_header_cell_pair}    ${key}=${value_text}
        END
    END

    ${delete_btn}    Set Variable    ${row}[Ações][Excluir]
    Scroll Element Into View    locator=${delete_btn}
    Set Focus To Element        locator=${delete_btn}
    Click Element               locator=${delete_btn}
    
    RETURN    ${row_header_cell_pair}
