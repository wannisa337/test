*** Settings ***
Documentation     SauceDemo UI tests using Excel data and YAML configuration.
...               Run: robot --outputdir results tests/saucedemo.robot
Library           SeleniumLibrary    timeout=${EXPLICIT_WAIT}
Library           DataDriver         file=${CURDIR}/../TestData.xlsx    sheet_name=TestData
Library           String
Library           Collections
Variables         ${CURDIR}/../config_variables.py    config.yaml
Suite Setup       Open SauceDemo
Suite Teardown    Close All Browsers
Test Template     Run Test Scenario

*** Test Cases ***
${testcase_name}    ${scenario}    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}

*** Keywords ***
Open SauceDemo
    ${options}=    Evaluate    __import__('selenium.webdriver', fromlist=['ChromeOptions']).ChromeOptions()

    IF    ${HEADLESS}
        Evaluate    $options.add_argument("--headless=new")
    END

    Evaluate    $options.add_argument("--window-size=1440,1000")

    Open Browser    ${BASE_URL}    ${BROWSER}    options=${options}

    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Maximize Browser Window

    Wait Until Element Is Visible    id=user-name    ${EXPLICIT_WAIT}

Run Test Scenario
    [Arguments]    ${scenario}    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}
    Go To    ${BASE_URL}
    Wait Until Element Is Visible    id=user-name    ${EXPLICIT_WAIT}
    IF    '${scenario}' == 'purchase_success'
        Successful Purchase    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}
    ELSE IF    '${scenario}' == 'locked_user'
        Login And Check Error    ${username}    ${password}    ${expected_result}
    ELSE IF    '${scenario}' == 'invalid_login'
        Login And Check Error    ${username}    ${password}    ${expected_result}
    ELSE IF    '${scenario}' == 'checkout_missing_first_name'
        Checkout Missing Field    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}    first_name
    ELSE IF    '${scenario}' == 'checkout_missing_last_name'
        Checkout Missing Field    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}    last_name
    ELSE IF    '${scenario}' == 'checkout_missing_postal'
        Checkout Missing Field    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}    postal_code
    ELSE IF    '${scenario}' == 'cart_remove'
        Cart Remove Item    ${username}    ${password}    ${items_to_add}    ${expected_result}
    ELSE IF    '${scenario}' == 'sort_price_low_high'
        Sort Price Low To High    ${username}    ${password}    ${expected_result}
    ELSE
        Fail    Unknown scenario: ${scenario}
    END

Login
    [Arguments]    ${username}    ${password}
    Input Text    id=user-name    ${username}
    Input Password    id=password    ${password}
    Click Button    id=login-button

Login And Check Error
    [Arguments]    ${username}    ${password}    ${expected_result}
    Login    ${username}    ${password}
    Wait Until Element Is Visible    css=[data-test="error"]    ${EXPLICIT_WAIT}
    ${actual}=    Get Text    css=[data-test="error"]
    Should Be Equal    ${actual}    ${expected_result}

Successful Purchase
    [Arguments]    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}
    Login    ${username}    ${password}
    Wait Until Element Is Visible    class=inventory_list    ${EXPLICIT_WAIT}
    Add Items To Cart    ${items_to_add}
    Click Link    class=shopping_cart_link
    Wait Until Element Is Visible    id=checkout    ${EXPLICIT_WAIT}
    Click Button    id=checkout
    Fill Checkout Information    ${first_name}    ${last_name}    ${postal_code}
    Click Button    id=continue
    Wait Until Element Is Visible    class=checkout_summary_container    ${EXPLICIT_WAIT}
    Click Button    id=finish
    Wait Until Element Is Visible    class=complete-header    ${EXPLICIT_WAIT}
    ${actual}=    Get Text    class=complete-header
    Should Be Equal    ${actual}    ${expected_result}

Add Items To Cart
    [Arguments]    ${items_to_add}
    @{items}=    Split String    ${items_to_add}    ,
    FOR    ${item}    IN    @{items}
        ${clean_item}=    Strip String    ${item}
        ${locator}=    Set Variable    xpath=//div[@class="inventory_item" and .//div[@class="inventory_item_name" and normalize-space()="${clean_item}"]]//button
        Wait Until Element Is Visible    ${locator}    ${EXPLICIT_WAIT}
        Click Button    ${locator}
    END

Fill Checkout Information
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Input Text    id=first-name    ${first_name}
    Input Text    id=last-name    ${last_name}
    Input Text    id=postal-code    ${postal_code}

Checkout Missing Field
    [Arguments]    ${username}    ${password}    ${items_to_add}    ${first_name}    ${last_name}    ${postal_code}    ${expected_result}    ${missing_field}
    Login    ${username}    ${password}
    Wait Until Element Is Visible    class=inventory_list    ${EXPLICIT_WAIT}
    Add Items To Cart    ${items_to_add}
    Click Link    class=shopping_cart_link
    Click Button    id=checkout
    Fill Checkout Information    ${first_name}    ${last_name}    ${postal_code}
    IF    '${missing_field}' == 'first_name'
        Clear Element Text    id=first-name
    ELSE IF    '${missing_field}' == 'last_name'
        Clear Element Text    id=last-name
    ELSE IF    '${missing_field}' == 'postal_code'
        Clear Element Text    id=postal-code
    END
    Click Button    id=continue
    Wait Until Element Is Visible    css=[data-test="error"]    ${EXPLICIT_WAIT}
    ${actual}=    Get Text    css=[data-test="error"]
    Should Be Equal    ${actual}    ${expected_result}

Cart Remove Item
    [Arguments]    ${username}    ${password}    ${items_to_add}    ${expected_result}
    Login    ${username}    ${password}
    Wait Until Element Is Visible    class=inventory_list    ${EXPLICIT_WAIT}
    Add Items To Cart    ${items_to_add}
    Click Link    class=shopping_cart_link
    ${before}=    Get Element Count    class=cart_item
    Should Be True    ${before} > 0
    ${first_name}=    Get Text    xpath=(//div[@class="cart_item"]//div[@class="inventory_item_name"])[1]
    Should Be Equal    ${first_name}    ${expected_result}
    Click Button    xpath=(//div[@class="cart_item"]//button[contains(@class,"cart_button")])[1]
    ${after}=    Get Element Count    class=cart_item
    Should Be Equal As Integers    ${after}    ${before-1}
    Page Should Not Contain    ${expected_result}

Sort Price Low To High
    [Arguments]    ${username}    ${password}    ${expected_result}
    Login    ${username}    ${password}
    Wait Until Element Is Visible    class=inventory_list    ${EXPLICIT_WAIT}
    Select From List By Value    class=product_sort_container    lohi
    ${prices}=    Get WebElements    class=inventory_item_price
    @{actual_prices}=    Create List
    FOR    ${price_element}    IN    @{prices}
        ${price_text}=    Get Text    ${price_element}
        ${number}=    Evaluate    float($price_text.replace('$',''))
        Append To List    ${actual_prices}    ${number}
    END
    ${sorted_prices}=    Evaluate    sorted($actual_prices)
    Should Be Equal    ${actual_prices}    ${sorted_prices}
    Should Be Equal    ${expected_result}    prices_sorted_low_to_high

