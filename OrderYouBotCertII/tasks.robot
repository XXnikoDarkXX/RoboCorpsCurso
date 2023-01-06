*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.HTTP
Library             RPA.Browser    auto_close=${FALSE}
Library             RPA.Tables
Library             RPA.PDF
Library    RPA.Archive
Library    OperatingSystem


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open browser Robot Order
    dowload order
    Csv to Collection
    Create ZIP package from PDF files


*** Keywords ***
dowload order
    Download    https://robotsparebinindustries.com/orders.csv

Open Browser Robot Order
    ## Set Selenium Speed    0.5
    Open Browser    https://robotsparebinindustries.com/#/robot-order    chrome

Click Ok PoPUp
    Click Button    OK

Csv to Collection
    ${Orders}=    Read table from CSV    ./orders.csv    header=True
    Create Directory   ${OUTPUT_DIR}${/}Order    
    
    FOR    ${Order}    IN    @{Orders}
        Click Ok PoPUp
        Create Order    ${Order}
    END

Create Order
    [Arguments]    ${Order}

    Select From List By Value    head    ${Order}[Head]
    Click Element    id:id-body-${Order}[Body]
    Select From List By Value    head    ${Order}[Head]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${Order}[Legs]
    Input Text    address    ${Order}[Address]
    Wait Until Element Is Enabled    id:order
    Set Focus To Element    id:order

    Wait Until Element Is Enabled    id:order
    Wait Until Keyword Succeeds    5x    2 sec    Click Button    id:order
    ## ${ExisteIdOrder}=    Page Should Contain Button    id:order
    ${statusOrder}=    Get Element Status    id:order
    ${contador}=    Set Variable    0

    WHILE    ${statusOrder}[enabled] == True and ${contador}<5
        Click Button    id:order
        ${contador}=    Evaluate    int(${contador}) + int(1)
        ${statusOrder}=    Get Element Status    id:order
    END
    Wait Until Element Is Visible    id:receipt

    ${receipHTML}=    Get Element Attribute    id:receipt    outerHTML
   ## Html To Pdf    ${receipHTML}    ${OUTPUT_DIR}${/}${Order}[Order number].pdf
    Html To Pdf    ${receipHTML}    ${OUTPUT_DIR}${/}Order${/}${Order}[Order number].pdf

    Take Screenshot Order    ${Order}
    ${files}=    Create List    ${OUTPUT_DIR}${/}${Order}[Order number].png
    ##    ...    ${OUTPUT_DIR}${/}${Order}[Order number].pdf      
    ##Add Image To PDF    ${files}    ${OUTPUT_DIR}${/}${Order}[Order number].pdf
    Add Image To PDF    ${files}    ${OUTPUT_DIR}${/}Order${/}${Order}[Order number].pdf
    Click Button    id:order-another
    ## {'Address': 'Address 123', 'Body': '2', 'Head': '1', 'Legs': '3', 'Order number': '1'}

Take Screenshot Order
    [Arguments]    ${Order}
    Screenshot    id:receipt    ${OUTPUT_DIR}${/}${Order}[Order number].png

Add Image To PDF
    [Arguments]    ${files}    ${pdf}
    Add Files To PDF    ${files}    ${pdf}    True

Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/OrderYouBotCertIIPDFs.zip
    Archive Folder With Zip         ${OUTPUT_DIR}${/}Order     ${zip_file_name}   