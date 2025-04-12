@echo off
setlocal enabledelayedexpansion
cls
title Chrome Extension Stripe Payment Implementation Guide

:main_menu
cls
echo =======================================================
echo   CHROME EXTENSION STRIPE PAYMENT IMPLEMENTATION GUIDE
echo =======================================================
echo.
echo This script will guide you through implementing Stripe payments in your Chrome extension.
echo.
echo MAIN MENU:
echo [1] Create Directory Structure
echo [2] Create Payment-Related Files
echo [3] Set Up Backend
echo [4] Configure Stripe
echo [5] Update Configuration Files
echo [6] Update Extension Files
echo [7] Start the Backend Server
echo [8] Test the Implementation
echo [9] Production Deployment
echo [10] Exit
echo.
set /p choice=Enter your choice (1-10): 

if "%choice%"=="1" goto create_directory
if "%choice%"=="2" goto create_payment_files
if "%choice%"=="3" goto setup_backend
if "%choice%"=="4" goto configure_stripe
if "%choice%"=="5" goto update_configs
if "%choice%"=="6" goto update_extension
if "%choice%"=="7" goto start_backend
if "%choice%"=="8" goto test_implementation
if "%choice%"=="9" goto production_deployment
if "%choice%"=="10" goto exit_script
goto main_menu

:create_directory
cls
echo =======================================================
echo   STEP 1: CREATE DIRECTORY STRUCTURE
echo =======================================================
echo.
echo This step will create the necessary directory structure for your implementation.
echo.
echo Required directories:
echo - payment
echo - server
echo.
set /p confirm=Do you want to create these directories? (Y/N): 
if /i "%confirm%"=="Y" (
    if not exist payment mkdir payment
    if not exist server mkdir server
    echo.
    echo Directories created successfully!
) else (
    echo.
    echo Directory creation skipped.
)
echo.
pause
goto main_menu

:create_payment_files
cls
echo =======================================================
echo   STEP 2: CREATE PAYMENT-RELATED FILES
echo =======================================================
echo.
echo This step will guide you through creating the payment-related files.
echo.
echo Files to create:
echo 1. payment/payment.html - The payment page
echo 2. payment/payment.js - Payment logic
echo 3. payment/success.html - Success page after payment
echo 4. payment/cancel.html - Cancellation page
echo.
echo You mentioned you have these files already.
echo Let's verify they exist:
echo.

set missing_files=0
if not exist payment\payment.html (
    echo [MISSING] payment/payment.html
    set /a missing_files+=1
) else (
    echo [FOUND] payment/payment.html
)

if not exist payment\payment.js (
    echo [MISSING] payment/payment.js
    set /a missing_files+=1
) else (
    echo [FOUND] payment/payment.js
)

if not exist payment\success.html (
    echo [MISSING] payment/success.html
    set /a missing_files+=1
) else (
    echo [FOUND] payment/success.html
)

if not exist payment\cancel.html (
    echo [MISSING] payment/cancel.html
    set /a missing_files+=1
) else (
    echo [FOUND] payment/cancel.html
)

echo.
if %missing_files% GTR 0 (
    echo Some files are missing. Would you like to create template files for the missing ones?
    set /p create_missing=Create missing files? (Y/N): 
    if /i "!create_missing!"=="Y" (
        if not exist payment\payment.html (
            echo. > payment\payment.html
            echo Created payment/payment.html template
        )
        if not exist payment\payment.js (
            echo. > payment\payment.js
            echo Created payment/payment.js template
        )
        if not exist payment\success.html (
            echo. > payment\success.html
            echo Created payment/success.html template
        )
        if not exist payment\cancel.html (
            echo. > payment\cancel.html
            echo Created payment/cancel.html template
        )
    )
) else (
    echo All payment files exist! 
)
echo.
pause
goto main_menu

:setup_backend
cls
echo =======================================================
echo   STEP 3: SET UP BACKEND
echo =======================================================
echo.
echo This step will set up the backend server for handling Stripe payments.
echo.
echo Files needed:
echo 1. server/package.json - Dependencies and scripts
echo 2. server/server.js - Server implementation
echo 3. server/.env.example - Environment variables template
echo 4. server/README.md - Documentation

set missing_backend=0
if not exist server\package.json (
    echo [MISSING] server/package.json
    set /a missing_backend+=1
) else (
    echo [FOUND] server/package.json
)

if not exist server\server.js (
    echo [MISSING] server/server.js
    set /a missing_backend+=1
) else (
    echo [FOUND] server/server.js
)

if not exist server\.env.example (
    echo [MISSING] server/.env.example
    set /a missing_backend+=1
) else (
    echo [FOUND] server/.env.example
)

if not exist server\README.md (
    echo [MISSING] server/README.md
    set /a missing_backend+=1
) else (
    echo [FOUND] server/README.md
)

echo.
if %missing_backend% GTR 0 (
    echo Some backend files are missing. Would you like to create template files?
    set /p create_backend=Create missing files? (Y/N): 
    if /i "!create_backend!"=="Y" (
        if not exist server\package.json (
            echo. > server\package.json
            echo Created server/package.json template
        )
        if not exist server\server.js (
            echo. > server\server.js
            echo Created server/server.js template
        )
        if not exist server\.env.example (
            echo. > server\.env.example
            echo Created server/.env.example template
        )
        if not exist server\README.md (
            echo. > server\README.md
            echo Created server/README.md template
        )
    )
)

echo.
echo Do you want to install the server dependencies?
set /p install_deps=Install dependencies (requires Node.js)? (Y/N): 
if /i "%install_deps%"=="Y" (
    echo.
    echo Installing dependencies...
    cd server
    npm install express cors stripe dotenv
    cd ..
    echo Dependencies installed!
)

echo.
echo Do you want to create the .env file from .env.example?
set /p create_env=Create .env file? (Y/N): 
if /i "%create_env%"=="Y" (
    if exist server\.env.example (
        copy server\.env.example server\.env
        echo .env file created from template!
    ) else (
        echo .env.example doesn't exist. Creating a basic .env file...
        echo STRIPE_SECRET_KEY=your_stripe_secret_key > server\.env
        echo STRIPE_PRICE_ID=your_stripe_price_id >> server\.env
        echo STRIPE_WEBHOOK_SECRET=your_webhook_secret >> server\.env
        echo ALLOWED_ORIGINS=chrome-extension://your-extension-id >> server\.env
        echo Basic .env file created!
    )
)

echo.
pause
goto main_menu

:configure_stripe
cls
echo =======================================================
echo   STEP 4: CONFIGURE STRIPE
echo =======================================================
echo.
echo This step will help you configure your Stripe account for payments.
echo.
echo Required Stripe information:
echo 1. Stripe public key
echo 2. Stripe secret key
echo 3. Stripe price ID for your product
echo 4. Stripe webhook secret
echo.
echo Do you have a Stripe account set up?
set /p has_stripe=Do you have a Stripe account? (Y/N): 
if /i "%has_stripe%"=="N" (
    echo.
    echo Please create a Stripe account at https://stripe.com before continuing.
    echo After creating an account, come back to this step.
    echo.
    pause
    goto main_menu
)

echo.
echo STEPS TO CONFIGURE STRIPE:
echo 1. Log into your Stripe dashboard at https://dashboard.stripe.com
echo 2. Create a one-time payment product:
echo    - Go to Products > Add Product
echo    - Name your product (e.g., "Chrome Extension Pro")
echo    - Set a price (e.g., $9.99)
echo    - Save the product
echo 3. Get your API keys:
echo    - Go to Developers > API keys
echo    - Note your publishable key and secret key
echo 4. Set up webhook (for production):
echo    - Go to Developers > Webhooks
echo    - Add endpoint URL (your server URL + "/webhook")
echo    - Select events: payment_intent.succeeded, payment_intent.payment_failed
echo    - Get the webhook signing secret
echo.
echo Do you have all the required Stripe information?
set /p has_keys=Do you have your Stripe keys and price ID? (Y/N): 
if /i "%has_keys%"=="Y" (
    echo.
    echo Great! Let's update your configuration files with this information.
    echo.
    set /p stripe_pub=Enter your Stripe publishable key: 
    set /p stripe_secret=Enter your Stripe secret key: 
    set /p stripe_price=Enter your product's price ID: 
    set /p stripe_webhook=Enter your webhook secret (leave blank if not yet created): 
    set /p extension_id=Enter your Chrome extension ID: 
    
    if exist server\.env (
        echo Updating .env file...
        echo STRIPE_SECRET_KEY=!stripe_secret! > server\.env
        echo STRIPE_PRICE_ID=!stripe_price! >> server\.env
        echo STRIPE_WEBHOOK_SECRET=!stripe_webhook! >> server\.env
        echo ALLOWED_ORIGINS=chrome-extension://!extension_id! >> server\.env
        echo .env file updated!
    )
    
    echo.
    echo Do you want to update payment.js with your publishable key?
    set /p update_js=Update payment.js? (Y/N): 
    if /i "!update_js!"=="Y" (
        if exist payment\payment.js (
            echo Updating payment.js... 
            echo Please manually add this line to your payment.js:
            echo const STRIPE_PUBLIC_KEY = '!stripe_pub!';
        ) else (
            echo payment.js doesn't exist. Please create it first.
        )
    )
) else (
    echo.
    echo Please collect all the required Stripe information before continuing.
)

echo.
pause
goto main_menu

:update_configs
cls
echo =======================================================
echo   STEP 5: UPDATE CONFIGURATION FILES
echo =======================================================
echo.
echo This step will help you verify and update your configuration files.
echo.
echo Files to check:
echo 1. server/.env - Environment variables
echo 2. payment/payment.js - Stripe public key
echo.

if exist server\.env (
    echo [FOUND] server/.env
    echo.
    echo Current .env configuration:
    type server\.env
    echo.
    echo Are these settings correct?
    set /p correct_env=Update .env settings? (Y/N): 
    if /i "!correct_env!"=="Y" (
        echo.
        set /p stripe_secret=Enter your Stripe secret key: 
        set /p stripe_price=Enter your product's price ID: 
        set /p stripe_webhook=Enter your webhook secret: 
        set /p extension_id=Enter your Chrome extension ID: 
        
        echo Updating .env file...
        echo STRIPE_SECRET_KEY=!stripe_secret! > server\.env
        echo STRIPE_PRICE_ID=!stripe_price! >> server\.env
        echo STRIPE_WEBHOOK_SECRET=!stripe_webhook! >> server\.env
        echo ALLOWED_ORIGINS=chrome-extension://!extension_id! >> server\.env
        echo .env file updated!
    )
) else (
    echo [MISSING] server/.env
    echo Please run step 3 to create the .env file.
)

echo.
if exist payment\payment.js (
    echo [FOUND] payment/payment.js
    echo.
    echo Please verify that payment.js contains your Stripe public key:
    echo const STRIPE_PUBLIC_KEY = 'your_stripe_public_key';
    echo.
    echo Does payment.js have the correct Stripe public key?
    set /p correct_js=Update payment.js with Stripe public key? (Y/N): 
    if /i "!correct_js!"=="Y" (
        echo.
        set /p stripe_pub=Enter your Stripe publishable key: 
        echo.
        echo Please manually add this line to your payment.js:
        echo const STRIPE_PUBLIC_KEY = '!stripe_pub!';
    )
) else (
    echo [MISSING] payment/payment.js
    echo Please run step 2 to create payment.js.
)

echo.
pause
goto main_menu

:update_extension
cls
echo =======================================================
echo   STEP 6: UPDATE EXTENSION FILES
echo =======================================================
echo.
echo This step will guide you through updating your extension files.
echo.
echo Files to modify:
echo 1. manifest.json - Permissions and CSP
echo 2. background.js - Payment status checks
echo 3. popup.js - UI elements and payment flow
echo.

echo MANIFEST.JSON CHANGES:
echo Add these permissions to your manifest.json:
echo - "storage" - For storing payment status
echo - "identity" - For the payment flow
echo.
echo Add these content security policy entries:
echo - connect-src: Add your server domain and Stripe domains
echo - frame-src: Add checkout.stripe.com
echo.
echo Add web_accessible_resources for payment-related files
echo.
echo Do you need to update your manifest.json?
set /p update_manifest=Update manifest.json? (Y/N): 
if /i "%update_manifest%"=="Y" (
    if exist manifest.json (
        echo.
        echo Please manually update your manifest.json with these changes.
        echo Refer to the implementation guide for specific details.
    ) else (
        echo.
        echo manifest.json not found. Please create it first.
    )
)

echo.
echo BACKGROUND.JS CHANGES:
echo Add functions for:
echo - Checking payment status on extension load
echo - Storing payment status after successful payment
echo - Limiting features based on payment status
echo.
echo Do you need to update your background.js?
set /p update_bg=Update background.js? (Y/N): 
if /i "%update_bg%"=="Y" (
    if exist background.js (
        echo.
        echo Please manually update your background.js with these changes.
        echo Refer to the implementation guide for specific details.
    ) else (
        echo.
        echo background.js not found. Please create it first.
    )
)

echo.
echo POPUP.JS CHANGES:
echo Add code for:
echo - Displaying premium UI elements
echo - Handling "Upgrade to Pro" button clicks
echo - Opening payment page when upgrade button is clicked
echo - Refreshing UI based on payment status
echo.
echo Do you need to update your popup.js?
set /p update_popup=Update popup.js? (Y/N): 
if /i "%update_popup%"=="Y" (
    if exist popup.js (
        echo.
        echo Please manually update your popup.js with these changes.
        echo Refer to the implementation guide for specific details.
    ) else (
        echo.
        echo popup.js not found. Please create it first.
    )
)

echo.
pause
goto main_menu

:start_backend
cls
echo =======================================================
echo   STEP 7: START THE BACKEND SERVER
echo =======================================================
echo.
echo This step will help you start the backend server for testing.
echo.
echo Prerequisites:
echo - Node.js installed
echo - Dependencies installed in the server directory
echo - Properly configured .env file
echo.

if not exist server\package.json (
    echo server/package.json not found. Please run step 3 first.
    echo.
    pause
    goto main_menu
)

if not exist server\server.js (
    echo server/server.js not found. Please run step 3 first.
    echo.
    pause
    goto main_menu
)

if not exist server\.env (
    echo server/.env not found. Please run step 3 or 5 first.
    echo.
    pause
    goto main_menu
)

echo Are you ready to start the backend server?
set /p start_server=Start server? (Y/N): 
if /i "%start_server%"=="Y" (
    echo.
    echo Starting the server...
    echo.
    echo The server will run in a new window. Don't close it while testing.
    echo To stop the server, press Ctrl+C in the server window.
    echo.
    echo Press any key to start the server...
    pause > nul
    start cmd /k "cd server && npm run dev || node server.js"
    echo.
    echo Server started in a new window!
) else (
    echo.
    echo Server startup skipped.
)

echo.
pause
goto main_menu

:test_implementation
cls
echo =======================================================
echo   STEP 8: TEST THE IMPLEMENTATION
echo =======================================================
echo.
echo This step will guide you through testing your Stripe payment implementation.
echo.
echo Testing checklist:
echo 1. Load your extension in Chrome:
echo    - Go to chrome://extensions/
echo    - Enable Developer mode
echo    - Click "Load unpacked" and select your extension directory
echo.
echo 2. Test free tier limitations:
echo    - Use the extension's free features
echo    - Verify that premium features are locked
echo.
echo 3. Test the payment flow:
echo    - Click "Upgrade to Pro"
echo    - Verify that the payment page opens
echo    - Use Stripe test cards (4242 4242 4242 4242) for successful payment
echo    - Use Stripe test cards (4000 0000 0000 0002) for declined payment
echo.
echo 4. Test success/cancel flows:
echo    - Verify redirection to success.html after successful payment
echo    - Verify redirection to cancel.html after cancelled payment
echo.
echo 5. Verify premium features:
echo    - Check that premium features are unlocked after payment
echo    - Verify that payment status persists after browser restart
echo.

echo Are you ready to test your implementation?
set /p ready_test=Start testing? (Y/N): 
if /i "%ready_test%"=="Y" (
    echo.
    echo Testing checklist:
    
    echo.
    echo 1. Is your extension loaded in Chrome?
    set /p test1=Extension loaded? (Y/N): 
    
    echo.
    echo 2. Are free tier limitations working?
    set /p test2=Free tier limitations working? (Y/N): 
    
    echo.
    echo 3. Does the payment page open when clicking "Upgrade to Pro"?
    set /p test3=Payment page opens? (Y/N): 
    
    echo.
    echo 4. Can you complete a test payment using Stripe test cards?
    set /p test4=Payment successful? (Y/N): 
    
    echo.
    echo 5. Are premium features unlocked after payment?
    set /p test5=Premium features unlocked? (Y/N): 
    
    echo.
    echo TEST RESULTS:
    echo Extension loaded: !test1!
    echo Free tier limits: !test2!
    echo Payment page: !test3!
    echo Payment success: !test4!
    echo Premium features: !test5!
    
    echo.
    if /i "!test1!"=="Y" if /i "!test2!"=="Y" if /i "!test3!"=="Y" if /i "!test4!"=="Y" if /i "!test5!"=="Y" (
        echo All tests passed! Your implementation is working correctly.
    ) else (
        echo Some tests failed. Please review the implementation guide and make necessary corrections.
    )
) else (
    echo.
    echo Testing skipped.
)

echo.
pause
goto main_menu

:production_deployment
cls
echo =======================================================
echo   STEP 9: PRODUCTION DEPLOYMENT
echo =======================================================
echo.
echo This step will guide you through deploying your implementation to production.
echo.
echo Production checklist:
echo 1. Deploy backend to hosting service:
echo    - Heroku, Vercel, Netlify, AWS, etc.
echo    - Set environment variables on the hosting platform
echo.
echo 2. Update payment.js with production backend URL:
echo    - Replace localhost URL with your deployed backend URL
echo.
echo 3. Update Stripe keys to production keys:
echo    - Replace test keys with live keys in .env and payment.js
echo.
echo 4. Test the complete flow in production:
echo    - Package your extension
echo    - Submit to Chrome Web Store if needed
echo    - Test with real payments
echo.
echo 5. Set up monitoring and alerts:
echo    - Monitor Stripe webhooks
echo    - Set up error reporting
echo.

echo Have you completed the production deployment?
set /p production_done=Production deployment completed? (Y/N/Skip): 
if /i "%production_done%"=="Y" (
    echo.
    echo Great! Your Stripe payment implementation is now in production.
    echo Make sure to monitor payments and provide support to your users.
) else if /i "%production_done%"=="N" (
    echo.
    echo Please follow the steps above to deploy your implementation to production.
    echo.
    echo IMPORTANT NOTES:
    echo - Always keep your Stripe secret key secure
    echo - Monitor Stripe webhooks for payment status
    echo - Implement proper error handling
    echo - Follow Chrome extension security best practices
) else (
    echo.
    echo Production deployment skipped.
)

echo.
pause
goto main_menu

:exit_script
cls
echo =======================================================
echo   THANK YOU FOR USING THE IMPLEMENTATION GUIDE
echo =======================================================
echo.
echo Your Stripe payment implementation for your Chrome extension should now be complete.
echo.
echo If you need further assistance, please refer to:
echo - Stripe documentation: https://stripe.com/docs
echo - Chrome extension documentation: https://developer.chrome.com/docs/extensions
echo.
echo Good luck with your Chrome extension!
echo.
pause
exit

:eof
