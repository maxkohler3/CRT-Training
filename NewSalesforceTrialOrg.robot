*** Settings ***

Documentation               New test suite
Library                     QWeb
Library                     QForce
Library                     DateTime
Library                     String
Library                     FakerLibrary
Suite Setup                 Open Browser                about:blank           chrome
Suite Teardown              Close All Browsers
*** Variables ***
${email}                  FakerLibrary.email
${BROWSER}                chrome
${username}               pace.delivery1@qentinel.com.demonew
${login_url}              https://qentinel--demonew.my.salesforce.com/            # Salesforce instance. NOTE: Should be overwritten in CRT variables
${home_url}               ${login_url}/lightning/page/home


*** Test Cases ***
Creating Trial Org
    GoTo                    https://www.salesforce.com/form/signup/freetrial-sales-pe/
    VerifyText              Start your free sales trial

    Evaluate                random.seed()               random
    ${exampleFirstName}=    Convert To String           guest1
    ${randomstring}=        Generate Random String      length=3-5            chars=0123456789
    ${FirstName}=           Format String               {}{}                  ${exampleFirstName}    ${randomstring}


    TypeText                First name                  ${FirstName}
    TypeText                Last name                   user
    TypeText                Job title                   Learner
    ClickText               Next

    DropDown                Employees                   21 - 200 employees
    TypeText                Company                     xyz
    ClickText               Next


    TypeText                Phone                       9999999999
    TypeText                Email                       ${email}
    ClickElement           //div[@class\="checkbox-ui"]                   

    ClickText               Submit

Create Case 
    [Documentation]       Create a case record
    ${home_url}           Set Variable         ${login_url}/lightning/page/home
    Appstate              Home

    LaunchApp             Cases
    ClickText             New
    UseModal              On
    PickList              *Status                     ${status}
    PickList              *Case Origin                ${case_origin}
    PickList              Priority                    ${priority}
    PickList              Type                        ${type}
    PickList              Case Reason                 ${case_reason}
    ClickText             Save                        partial_match=False
    UseModal              Off

    VerifyField           Status                      ${status}
    VerifyField           Case Origin                 ${case_origin}
    VerifyField           Priority                    ${priority}
    VerifyField           Type                        ${type}
    VerifyField           Case Reason                 ${case_reason}

    ${case_number}=       GetFieldValue               Case Number
    Set Suite Variable    ${case_number}

Edit Case Record 
    [Documentation]       Edit case record in service cloud
    Appstate              Home
    LaunchApp             Cases
    ClickText             ${case_number}
    ClickText             Edit                        anchor=Delete
    TypeText              Subject                     Something broke
    TypeText              Description                 the product arrvied broken upon delivery
    ClickText             Save                        partial_match=False

    VerifyField           Subject                     Something broke
    VerifyField           Description                 the product arrvied broken upon delivery


Entering A Lead
    [tags]                    Lead
    Appstate                  Home
    LaunchApp                 Sales
    ClickText                 Leads
    VerifyText                Change Owner
    ClickText                 New
    VerifyText                Lead Information
    UseModal                  On                          # Only find fields from open modal dialog

    Picklist                  Salutation                  Ms.
    TypeText                  First Name                  Tina
    TypeText                  Last Name                   Smith
    Picklist                  Lead Status                 New
    # generate random phone number, just as an example
    # NOTE: initialization of random number generator is done on suite setup
    ${rand_phone}=            Generate Random String      14                          [NUMBERS]
    # concatenate leading "+" and random numbers
    ${phone}=                 SetVariable                 +${rand_phone}
    TypeText                  Phone                       ${phone}                    First Name
    TypeText                  Company                     Growmore                    Last Name
    TypeText                  Title                       Manager                     Address Information
    TypeText                  Email                       tina.smith@gmail.com        Rating
    TypeText                  Website                     https://www.growmore.com/

    Picklist                  Lead Source                 Partner
    ClickText                 Save                        partial_match=False
    UseModal                  Off
    Sleep                     1

    #*** clicking wrong Details... solution- anchor=Activity
    ClickText                 Details                     anchor=Activity
    VerifyField               Name                        Ms. Tina Smith
    VerifyField               Lead Status                 New
    VerifyField               Phone                       ${phone}
    VerifyField               Company                     Growmore
    VerifyField               Website                     https://www.growmore.com/

    # as an example, let's check Phone number format. Should be "+" and 14 numbers
    ${phone_num}=             GetFieldValue               Phone
    Should Match Regexp	      ${phone_num}	              ^[+]\\d{14}$
    
    ClickText                 Leads
    VerifyText                Tina Smith
    VerifyText                Manager
    VerifyText                Growmore


Converting A Lead To Opportunity-Account-Contact
    [tags]                    Lead
    Appstate                  Home
    LaunchApp                 Sales

    ClickText                 Leads
    ClickText                 Tina Smith

    #*** Clicking wrong convert.... solution-  ClickText    Show more actions
    ClickText    Show more actions
    ClickUntil                Convert Lead                Convert     
    ClickText                 Opportunity                 2
    TypeText                  Opportunity Name            Growmore Pace
    ClickText                 Convert                     2
    VerifyText                Your lead has been converted                            timeout=30

    ClickText                 Go to Leads
    ClickText                 Opportunities
    VerifyText                Growmore Pace
    ClickText                 Accounts
    VerifyText                Growmore
    ClickText                 Contacts
    VerifyText                Tina Smith


Creating An Account
    [tags]                    Account
    Appstate                  Home
    LaunchApp                 Sales

    ClickText                 Accounts
    ClickUntil                Account Information         New

    TypeText                  Account Name                Salesforce                  anchor=Parent Account
    TypeText                  Phone                       +12258443456789             anchor=Fax
    
    #*** there is no fax field... solution- remove below step
    #TypeText                  Fax                         +12258443456766
    TypeText                  Website                     https://www.salesforce.com
    Picklist                  Type                        Partner
    Picklist                  Industry                    Finance

    TypeText                  Employees                   35000
    #*** there is no annual revenue field... solution- remove below step
    #TypeText                  Annual Revenue              12 billion
    ClickText                 Save                        partial_match=False

    ClickText                 Details
    VerifyText                Salesforce
    VerifyText                35,000


Creating An Opportunity For The Account
    [tags]                    Account
    Appstate                  Home
    LaunchApp                 Sales
    ClickText                 Accounts
    VerifyText                Salesforce
    VerifyText                Opportunities

    ClickUntil                Stage                       Opportunities
    ClickUntil                Opportunity Information     New
    TypeText                  Opportunity Name            Safesforce Pace             anchor=Cancel   delay=2
    Combobox                  Search Accounts...          Salesforce
    Picklist                  Type                        New Business
    ClickText                 Close Date                  Opportunity Information
    ClickText                 Next Month
    ClickText                 Today

    #*** there is no prospecting stage.... solution- update script to reflect actual picklist option (Proposal)
    Picklist                  Stage                       Proposal
    TypeText                  Amount                      5000000
    Picklist                  Lead Source                 Partner
    TypeText                  Next Step                   Qualification
    TypeText                  Description                 This is first step
    ClickText                 Save                        partial_match=False         # Do not accept partial match, i.e. "Save All"

    Sleep                     1
    ClickText                 Opportunities

    #*** there is no Safesforce Pace opp.... solution- replace Safesforce with Growmore
    VerifyText                Growmore Pace


Change status of opportunity
    [tags]                    status_change
    Appstate                  Home
    ClickText                 Opportunities
    #*** there is no Safesforce Pace opp.... solution- replace Safesforce with Growmore
    ClickText                 Growmore Pace             delay=2                     # intentionally delay action - 2 seconds
    VerifyText                Contact Roles

    ClickText                 Show actions for Contact Roles
    ClickText                 Add Contact Roles

    # verify all following texts from the dialog that opens
    VerifyAll                 Cancel, Show Selected, Name, Add Contact Roles
    ComboBox                  Search Contacts...          Tina Smith
    ClickText                 Next                        delay=3
    ClickText                 Edit Role: Item 1
    ClickText                 --None--
    ClickText                 Decision Maker
    ClickText                 Save                        partial_match=False
    VerifyText                Tina Smith

    ClickText                 Mark Stage as Complete
    ClickText                 Opportunities               delay=2
    #*** there is no Safesforce Pace opp.... solution- replace Safesforce with Growmore
    ClickText                 Growmore Pace

    #*** not in Qualification stage... solution- change stage to Needs Analysis
    VerifyStage               Needs Analysis               true

    #*** no Prospecting stage... solution- change stage to Qualification
    VerifyStage               Qualification                 false


Create A Contact For The Account
    [tags]                    salesforce.Account
    Appstate                  Home
    LaunchApp                 Sales
    ClickText                 Accounts
    VerifyText                Salesforce
    VerifyText                Contacts

    ClickUntil                Email                       Contacts
    ClickUntil                Contact Information         New
    Picklist                  Salutation                  Mr.
    TypeText                  First Name                  Richard
    TypeText                  Last Name                   Brown
    TypeText                  Phone                       +00150345678134             anchor=Mobile
    TypeText                  Mobile                      +00150345678178
    Combobox                  Search Accounts...          Salesforce

    TypeText                  Email                       richard.brown@gmail.com     anchor=Reports To
    TypeText                  Title                       Manager
    ClickText                 Save                        partial_match=False
    Sleep                     1
    ClickText                 Contacts
    VerifyText                Richard Brown


Delete Test Data
    [tags]                    Test data

    #*** need to update cleanup......
    
    Appstate                  Home
    LaunchApp                 Sales
    ClickText                 Accounts

    Set Suite Variable        ${data}                     Salesforce
    RunBlock                  NoData                      timeout=180s                exp_handler=DeleteAccounts
    Set Suite Variable        ${data}                     Growmore
    RunBlock                  NoData                      timeout=180s                exp_handler=DeleteAccounts

    ClickText                 Opportunities
    VerifyText                0 items
    VerifyNoText              Safesforce Pace
    VerifyNoText              Growmore Pace
    VerifyNoText              Richard Brown
    VerifyNoText              Tina Smith

    # Delete Leads
    ClickText                 Leads
    VerifyText                Change Owner
    Set Suite Variable        ${data}                     Tina Smith
    RunBlock                  NoData                      timeout=180s                exp_handler=DeleteLeads
    Set Suite Variable        ${data}                     John Doe
    RunBlock                  NoData                      timeout=180s                exp_handler=DeleteLeads
    
LoginAs Example
     [Documentation]           Example how to impersonate another user. Note: Admin rights needed
     ...                       for the user who tries to impersonate another user
     Appstate                  Home
     LoginAs                   Chatter Expert
     VerifyText                Salesforce Chatter
    

*** Keywords ***
Setup Browser
    # Setting search order is not really needed here, but given as an example 
    # if you need to use multiple libraries containing keywords with duplicate names
    Set Library Search Order                          QForce    QWeb
    Open Browser          about:blank                 ${BROWSER}
    SetConfig             LineBreak                   ${EMPTY}               #\ue000
    SetConfig             DefaultTimeout              20s                    #sometimes salesforce is slow
    Evaluate              random.seed()               random                 # initialize random generator


End suite
    Close All Browsers


Login
    [Documentation]       Login to Salesforce instance
    GoTo                  ${login_url}
    TypeText              Username                    ${username}             delay=1
    TypeText              Password                    ${password}
    ClickText             Log In
    # We'll check if variable ${secret} is given. If yes, fill the MFA dialog.
    # If not, MFA is not expected.
    # ${secret} is ${None} unless specifically given.
    ${MFA_needed}=       Run Keyword And Return Status          Should Not Be Equal    ${None}       ${secret}
    Run Keyword If       ${MFA_needed}               Fill MFA


Login As
    [Documentation]       Login As different persona. User needs to be logged into Salesforce with Admin rights
    ...                   before calling this keyword to change persona.
    ...                   Example:
    ...                   LoginAs    Chatter Expert
    [Arguments]           ${persona}
    ClickText             Setup
    ClickText             Setup for current app
    SwitchWindow          NEW
    TypeText              Search Setup                ${persona}             delay=2
    ClickText             User                        anchor=${persona}      delay=5    # wait for list to populate, then click
    VerifyText            Freeze                      timeout=45                        # this is slow, needs longer timeout          
    ClickText             Login                       anchor=Freeze          delay=1      

Fill MFA
    ${mfa_code}=         GetOTP    ${username}   ${secret}   ${login_url}    
    TypeSecret           Verification Code       ${mfa_code}      
    ClickText            Verify 


Home
    [Documentation]       Navigate to homepage, login if needed
    GoTo                  ${home_url}
    ${login_status} =     IsText                      To access this page, you have to log in to Salesforce.    2
    Run Keyword If        ${login_status}             Login
    ClickText             Home
    VerifyTitle           Home | Salesforce


# Example of custom keyword with robot fw syntax
VerifyStage
    [Documentation]       Verifies that stage given in ${text} is at ${selected} state; either selected (true) or not selected (false)
    [Arguments]           ${text}                     ${selected}=true
    VerifyElement        //a[@title\="${text}" and (@aria-checked\="${selected}" or @aria-selected\="${selected}")]


NoData
    VerifyNoText          ${data}                     timeout=3                        delay=2


DeleteAccounts
    [Documentation]       RunBlock to remove all data until it doesn't exist anymore
    ClickText             ${data}
    ClickText             Delete
    VerifyText            Are you sure you want to delete this account?
    ClickText             Delete                      2
    VerifyText            Undo
    VerifyNoText          Undo
    ClickText             Accounts                    partial_match=False


DeleteLeads
    [Documentation]       RunBlock to remove all data until it doesn't exist anymore
    ClickText             ${data}
    ClickText             Delete
    VerifyText            Are you sure you want to delete this lead?
    ClickText             Delete                      2
    VerifyText            Undo
    VerifyNoText          Undo
    ClickText             Leads                    partial_match=False

