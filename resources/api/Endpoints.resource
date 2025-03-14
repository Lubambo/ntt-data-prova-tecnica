*** Settings ***
Documentation    Endoints strings handler.

Variables        ${EXECDIR}/configuration/locators.py

*** Variables ***
${api_url}              ${SETTINGS}[DEFAULT][API_URL]
${login_endpoint}       ${api_url}/login
${users_endpoint}       ${api_url}/usuarios
${products_endpoint}    ${api_url}/produtos

&{default_headers}     Content-Type=application/json
