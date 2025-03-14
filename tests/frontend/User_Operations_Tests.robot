*** Settings ***
Documentation    Validate user related features.

Resource         ${EXECDIR}/resources/pages/Login_Page.resource
Resource         ${EXECDIR}/resources/pages/Register_User_Page.resource
Resource         ${EXECDIR}/resources/pages/Users_List_Page.resource
Resource         ${EXECDIR}/resources/utils/Entity_Generator.resource

Suite Setup      Access Application And Login    create_user_if_not_exists=${true}

*** Variables ***
&{random_user}    &{EMPTY}

*** Test Cases ***
Successful resgistration of a new user
    [Documentation]    Verify the application is able to register a new user.
    [Tags]             smoke    regression    user-operations

    Access Navigation Menu Item           item_title=${header_nav_bar_item_title_register_users}
    Check If Location Is Expected Page    page_title=${register_user_page_title}

    &{user}    Generate Random User
    Set Suite Variable    &{random_user}    &{user}

    Register New User    user_name=${user}[${users_list_page_table_header_name}]            user_email=${user}[${users_list_page_table_header_email}]    
    ...                  user_password=${user}[${users_list_page_table_header_password}]    user_is_administrator=${user}[${users_list_page_table_header_administrator}]
    
    Check If Location Is Expected Page    page_title=${users_list_page_title}
    
    ${searched_user}    Find User    header_cell_pair=${random_user}
    @{ignore_keys}      Create List    Ações
    Dictionaries Should Be Equal    ${searched_user}    ${random_user}    ignore_keys=${ignore_keys}

Verify users list display values
    [Documentation]    Verify the users list is displaying values as expected.
    [Tags]             smoke    regression    user-operations
    
    Access Navigation Menu Item           item_title=${header_nav_bar_item_title_list_users}
    Check If Location Is Expected Page    page_title=${users_list_page_title}

    ${users_count}    Count Users

    IF    ${users_count} < ${1}
        Access Navigation Menu Item           item_title=${header_nav_bar_item_title_register_users}
        Check If Location Is Expected Page    page_title=${register_user_page_title}

        ${user}    Generate Random User
        Set Suite Variable    &{random_user}    &{user}

        Register New User    user_name=${user}[${users_list_page_table_header_name}]            user_email=${user}[${users_list_page_table_header_email}]    
        ...                  user_password=${user}[${users_list_page_table_header_password}]    user_is_administrator=${user}[${users_list_page_table_header_administrator}]
        
        Check If Location Is Expected Page    page_title=${users_list_page_title}
    END
    
    @{users}    Get All Users    limit=${1}

    @{keys}    Get Dictionary Keys    ${users}[0]

    @{headers}    Create List    ${users_list_page_table_header_name}
    ...                          ${users_list_page_table_header_email}
    ...                          ${users_list_page_table_header_password}
    ...                          ${users_list_page_table_header_administrator}
    
    ${keys_count}       Get Length    ${keys}
    ${headers_count}    Get Length    ${headers}
    Should Be Equal    ${headers_count}    ${keys_count}

    List Should Contain Sub List    ${headers}    ${keys}
    
Successful user removal
    [Documentation]    Verify that a user can be successfully deleted.
    [Tags]             smoke    regression    user-operations
    
    @{keys}          Get Dictionary Keys    ${random_user}
    ${keys_count}    Get Length             ${keys}

    IF    ${keys_count} < ${1}
        Access Navigation Menu Item           item_title=${header_nav_bar_item_title_register_users}
        Check If Location Is Expected Page    page_title=${register_user_page_title}

        &{user}    Generate Random User
        Set Suite Variable    &{random_user}    &{user}

        Register New User    user_name=${user}[${users_list_page_table_header_name}]            user_email=${user}[${users_list_page_table_header_email}]    
        ...                  user_password=${user}[${users_list_page_table_header_password}]    user_is_administrator=${user}[${users_list_page_table_header_administrator}]
    ELSE
      Access Navigation Menu Item           item_title=${header_nav_bar_item_title_list_users}
      Check If Location Is Expected Page    page_title=${users_list_page_title}
    END
    
    Delete User    header_cell_pair=${random_user}