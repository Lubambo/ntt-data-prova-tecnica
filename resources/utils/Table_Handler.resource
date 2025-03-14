*** Settings ***
Documentation    Useful keywords to handle operations related to table HTML tag.

Library          SeleniumLibrary
Library          String
Library          Collections

*** Keywords ***
Get Table Rows Count
    [Documentation]    Return the number of rows in the table.
    [Arguments]        ${table_locator}

    ${rows_locator}    Catenate    SEPARATOR=${EMPTY}    ${table_locator}    /tbody/tr

    Wait Until Element Is Visible    locator=${rows_locator}

    @{rows}     Get WebElements    locator=${rows_locator}
    ${count}    Get Length        ${rows}

    IF    ${count} < ${1}
        @{rows}     Get WebElements    locator=${rows_locator}
        ${count}    Get Length        ${rows}
    END

    RETURN    ${count}

Get Table Headers
    [Documentation]    Return the table headers as a list of strings.
    [Arguments]        ${table_locator}

    @{headers}    Create List    @{EMPTY}

    ${header_locator}     Catenate           SEPARATOR=${EMPTY}    ${table_locator}    /thead//th
    @{header_elements}    Get WebElements    locator=${header_locator}

    FOR    ${element}    IN    @{header_elements}
        ${header}    Get Text    locator=${element}
        Append To List    ${headers}    ${header}
    END

    RETURN    ${headers}

Get Table Row
    [Documentation]    Return the table row as a dictionary that keys are the headers and values are the column value.
    ...                The headers argument is a list of header names that should have the value of the respective row column collected. If no list of header names is informed, it will take the values of all row columns.
    ...                If return_as_webelement is set as TRUE, the returned value will be a list of each row WebElement. Else, if it is set as FALSE, the returned value will be a list of each row xpath. By default it is set as TRUE.
    [Arguments]        ${table_locator}    ${row_index}    ${headers}=@{EMPTY}    ${return_as_webelement}=${true}
    
    &{row}    Create Dictionary    &{EMPTY}

    ${defined_headers_count}    Get Length    ${headers}
    IF    ${defined_headers_count} == ${0}
        ${headers}    Get Table Headers    table_locator=${table_locator}
    END

    ${cell_locator}    Set Variable    //table/tbody/tr[${row_index}]/td[count(//table/thead//th[normalize-space(text())='HEADER_TITLE']/preceding-sibling::th) + 1]
    FOR    ${header}    IN    @{headers}
        ${locator}    Replace String Using Regexp    string=${cell_locator}    pattern=HEADER_TITLE    replace_with=${header}

        ${cell_value}    Set Variable    ${none}

        ${child_node_locator}    Catenate    SEPARATOR=${EMPTY}    ${locator}    /descendant::*[last()]
        ${status}    ${child_node}    Run Keyword And Ignore Error    Get WebElement    ${child_node_locator}
        ${child_node_tag_name}    Set Variable    ${none}
        IF    '${status}' == 'PASS'
            ${child_node_tag_name}    Set Variable    ${child_node.tag_name}
        END

        IF    '${return_as_webelement}' == '${true}'
            IF    '${child_node_tag_name}' == 'button'
                ${child_node_locator}    Catenate    SEPARATOR=${EMPTY}    ${locator}    /descendant::button
                @{child_buttons}         Get WebElements    locator=${child_node_locator}
                
                &{buttons}    Create Dictionary    &{EMPTY}
                FOR    ${child_btn}    IN    @{child_buttons}
                    ${btn_text}    Get Text    locator=${child_btn}
                    Set To Dictionary    ${buttons}    ${btn_text}=${child_btn}
                END

                ${cell_value}    Set Variable    ${buttons}
            ELSE
                ${cell_value}    Get WebElement    locator=${locator}
            END
        ELSE
            IF    '${child_node_tag_name}' == 'button'
                ${cell_value}    Set Variable    ${none}
            ELSE
                ${cell_value}    Get Text    locator=${locator}
            END
        END

        Set To Dictionary    ${row}    ${header}=${cell_value}
    END
    
    RETURN    ${row}
  
Get All Table Rows
    [Documentation]    Return a list of table rows, in which each row is a dictionary that keys are the headers and values are the column value.
    ...                The headers argument is a list of header names that should have the value of the respective row column collected. If no list of header names is informed, it will take the values of all row columns.
    ...                If return_as_webelement is set as TRUE, the returned value will be a list of each row WebElement. Else, if it is set as FALSE, the returned value will be a list of each row xpath. By default it is set as TRUE.
    [Arguments]        ${table_locator}    ${headers}=@{EMPTY}    ${limit}=${-1}    ${return_as_webelement}=${true}
    
    @{rows}    Create List    @{EMPTY}

    ${rows_count}    Get Table Rows Count   table_locator=${table_locator}

    IF    ${rows_count} > ${0}
        ${defined_headers_count}    Get Length    ${headers}
        IF    ${defined_headers_count} == ${0}
            ${headers}    Get Table Headers    table_locator=${table_locator}
        END
        
        ${rows_limit}    Set Variable    ${limit}
        IF    ${limit} < ${1}
            ${rows_limit}    Set Variable    ${rows_count}
        END

        FOR    ${row_index}    IN RANGE    1    ${{${rows_limit} + 1}}
            ${row}    Get Table Row    table_locator=${table_locator}    row_index=${row_index}    headers=${headers}    return_as_webelement=${return_as_webelement}
            Append To List    ${rows}    ${row}
        END
    END

    RETURN    ${rows}
  
Find Table Row
    [Documentation]    Search for the first row that has the given cell values under the respective headers.
    ...                The cell value must be given as a dictionary in which the key is the header title and the value is the respective cell value.
    [Arguments]        ${table_locator}    ${header_cell_pair}    ${return_as_webelement}=${true}
    
    ${row}    Set Variable    ${none}
    
    ${rows_count}    Get Table Rows Count   table_locator=${table_locator}

    IF    ${rows_count} > ${0}
        ${row_locator}    Catenate    SEPARATOR=${EMPTY}    ${table_locator}    /tbody/tr[FILTERS]
            
        ${filter_locator}    Set Variable    ./td[count(//table/thead//th[normalize-space(text())='HEADER_TITLE']/preceding-sibling::th) + 1][normalize-space(text())='CELL_VALUE']

        @{filters}    Create List    @{EMPTY}
        FOR    ${key}    ${value}    IN    &{header_cell_pair}
            ${filter}    Replace String Using Regexp    string=${filter_locator}    pattern=HEADER_TITLE    replace_with=${key}
            ${filter}    Replace String    string=${filter}    search_for=CELL_VALUE    replace_with=${value}
            
            Append To List    ${filters}    ${filter}
        END

        ${filters_appendix}    Evaluate    " and ".join(${filters})

        ${row_locator}    Replace String    string=${row_locator}    search_for=FILTERS    replace_with=${filters_appendix}
        ${is_present}    Run Keyword And Return Status    Page Should Contain Element    ${row_locator}

        IF    '${is_present}' == '${true}'
            ${row_index}    Catenate    SEPARATOR=${EMPTY}    count(    ${row_locator}    [1]/preceding-sibling::tr) + 1
        
            @{headers}    Get Table Headers    table_locator=${table_locator}
            ${status}    ${found_row}    Run Keyword And Ignore Error    Get Table Row    ${table_locator}    ${row_index}    ${headers}    ${return_as_webelement}

            IF    '${status}' == 'FAIL'
                ${row}    Set Variable    ${none}
            ELSE
                ${row}    Set Variable    ${found_row}
            END
        END
    END
    
    RETURN    ${row}
