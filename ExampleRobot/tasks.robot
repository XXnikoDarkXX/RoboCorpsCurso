*** Settings ***
Documentation     Inserte los datos de ventas de la semana y expórtelos como PDF.
Library    RPA.Browser.Selenium   auto_close=${FALSE}

*** Tasks ***
Inserte los datos de ventas de la semana y expórtelos como PDF.
    Open the intranet website
    Log in
    Fill and submit the form
*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/  

Log in
    Input Text   id:username    maria
    Input Password    name:password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form
    
Fill and submit the form
    Input Text    firstname    John
    Input Text    lastname    Smith
    Input Text    salesresult    123
    Select From List By Value    salestarget    10000
    Click Button    Submit