*** Settings ***
Documentation    Users list page useful keywords.

Library          SeleniumLibrary
Library          String
Resource         Common_Page.resource
Resource         Register_User_Page.resource
Resource         ${EXECDIR}/resources/utils/Table_Handler.resource

*** Variables ***
${users_list_page_title}    Lista dos usuários

${users_list_page_table_header_name}             Nome
${users_list_page_table_header_email}            Email
${users_list_page_table_header_password}         Senha
${users_list_page_table_header_administrator}    Administrador
${users_list_page_table_header_action}           Ação

*** Keywords ***
Count Users
    [Documentation]    Return the number of users on the table.

    ${users_count}    Get Table Rows Count    table_locator=${common_page_table}
    RETURN    ${users_count}

Get All Users
    [Documentation]    Return all items in the users table.
    [Arguments]        ${limit}=${-1}    ${return_as_webelement}=${false}

    @{headers}    Create List    ${users_list_page_table_header_name}
    ...                          ${users_list_page_table_header_email}
    ...                          ${users_list_page_table_header_password}
    ...                          ${users_list_page_table_header_administrator}
    
    IF    '${return_as_webelement}' == '${true}'
        Append To List    ${headers}    ${users_list_page_table_header_action}
    END
       
    @{users}    Get All Table Rows    table_locator=${common_page_table}    headers=${headers}    limit=${limit}    return_as_webelement=${return_as_webelement}

    RETURN    ${users}
  
Find User
    [Documentation]    Find the first user in the table that has the headers containing the respective cell values.
    [Arguments]        ${header_cell_pair}    ${return_as_webelement}=${false}

    &{row}    Find Table Record    header_cell_pair=${header_cell_pair}    return_as_webelement=${return_as_webelement}
    RETURN    ${row}

Edit User
    [Documentation]    Edit a user in the users table. If no header_cell_pair value is given, in order to search a respective user, it will edit the first user in the table.
    [Arguments]        ${user_name}    ${user_email}    ${user_password}    ${user_is_administrator}    ${header_cell_pair}=&{EMPTY}

    Access Table Record Edit Action    header_cell_pair=${header_cell_pair}

    Register New User    user_name=${user_name}    user_email=${user_email}    user_password=${user_password}    
    ...                  user_is_administrator=${user_is_administrator}

Delete User
    [Documentation]    Delete a user in the users table. If no header_cell_pair value is given, in order to search a respective user, it will delete the first user in the table.
    [Arguments]        ${header_cell_pair}=&{EMPTY}

    ${deleted_record}    Delete Table Record    header_cell_pair=${header_cell_pair}

    ${searched_item}    Find User    header_cell_pair=${deleted_record}
    Should Be Equal    '${searched_item}'    '&{EMPTY}'