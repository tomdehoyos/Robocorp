*** Settings ***
Documentation     Robot to make orders from a CSV
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Tables
Library    RPA.Desktop
*** Variables ***
#this is the page for the orders
${main_page}    https://robotsparebinindustries.com/#/robot-order
#this is to download the csv file
${CSV_download}    https://robotsparebinindustries.com/orders.csv
#this is where we will be saving the pdf and the ss
${receipt}    C:/THR/Robocorp/create-zords/output/receipt_orders
${receipt_image}
#${robot_SS}    C:/THR/Robocorp/create-zords/output/receipt_orders
*** Tasks ***
#The robot should use the orders file (.csv ) and complete all the orders in the file.
#orders page
#Done
#https://robotsparebinindustries.com/#/robot-order
#Done
#Only the robot is allowed to get the orders file. You may not save the file manually on your computer.
#https://robotsparebinindustries.com/orders.csv
#Done
#The robot should save each order HTML receipt as a PDF file.
#The robot should save a screenshot of each of the ordered robots.
#The robot should embed the screenshot of the robot to the PDF receipt.
#The robot should create a ZIP archive of the PDF receipts (one zip archive that contains all the PDF files). Store the archive in the output directory.
#What library for zip is needed?
#The robot should complete all the orders even when there are technical failures with the robot order website.
#The robot should read some data from a local vault. In this case, do not store sensitive data such as credentials in the vault. The purpose is to verify that you know how to use the vault.
#The robot should use an assistant to ask some input from the human user, and then use that input some way.
#The robot should be available in public GitHub repository.
#Store the local vault file in the robot project repository so that it does not require manual setup.
#It should be possible to get the robot from the public GitHub repository and run it without manual setup.
Robot to make orders from a CSV
    ${tickets}=    Download csv file
    Open Order Robot
    FOR    ${row}    IN    @{tickets}
        Close Pop-up
        Fill Orders    ${row}
        Wait Until Keyword Succeeds    10    2s    Preview
        Robot SS  ${row}    #using order number?
        Order
        HTML PDF  
        #Order Screenshot
        #Order More        
    END
        #Close Pop-up
        #Fill Form from CSV
        #Fill Orders
        #Order Screenshot
        #Order More
*** Keywords ***
Download csv file
    #HTTP library
    Download     ${CSV_download}    overwrite=true
    ${orders}=    Read table from CSV    orders.csv
    #lets see if this works
    Log    ${orders}
    [Return]    ${orders}

Open Order Robot
    #rpa browser selenium library
    Open Chrome Browser    ${main_page}    maximized=true    
Close Pop-up
    Wait Until Element Is Visible    css:div.modal
    Click Button    OK 
Fill Orders
    [Arguments]   ${order}     
    Select From List By Value    id:head    ${order}[Head]  
    #[Head]

    Select Radio Button    body    ${order}[Body]
    #[Body]

    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    #[Legs]

    Input Text    id:address    ${order}[Address]
    #[Address]

Preview 
    Click Button    id:preview
Robot SS
    [Arguments]   ${ID}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${receipt}${/}${ID}[Order number]_image.png
    ${receipt_image}=    Set Variable    ${receipt}${/}${ID}[Order number]_image.png
    Open File    ${receipt_image}    
Order
    #wait
    Click Button    id:order
    Log    ${receipt_image}
HTML PDF
    Wait And Click Button    locator
Order Screenshot
    #this needs to be inside a for loop or something inside the fill form from CSV
    Wait Until Element Is Visible    id:robot-preview-image
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt
    #this gets the info for the pdf
    ${receipts_html}=    Get Element Attribute    id:receipt    outerHTML    
    #this is where we can change the sales results to an order number
    #this uses the html and saves it to the folder
    Html To Pdf    ${receipts_html}    ${receipt}${/}sales_results.pdf
    Wait Until Element Is Visible    id:robot-preview-image
    #this is where we can change the sales results to an order number
    Screenshot    id:robot-preview-image    ${receipt}${/}sales_results.png
    #${robot_SS}    Set Variable    ${robot_SS}${/}name.png
    #this needs to be a list
    #for lists is @{adfs}
    #whats robotname?

    @{add_image}    Create List    ${robotname}
    Open Pdf    ${htmlname}
    Add Files To Pdf    ${add_image}    ${htmlname}    append=True
    #retry the click order with another task!!!!!!!!!!

Order More
    Wait Until Element Is Visible    id:order-another
    Click Button    id:order-another