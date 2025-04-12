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
echo - payment (For frontend payment pages)
echo - server (For backend payment processing)
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
echo Let's verify these files exist:
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
            echo ^<!DOCTYPE html^> > payment\payment.html
            echo ^<html lang="en"^> >> payment\payment.html
            echo ^<head^> >> payment\payment.html
            echo     ^<meta charset="UTF-8"^> >> payment\payment.html
            echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> payment\payment.html
            echo     ^<title^>Upgrade to Pro^</title^> >> payment\payment.html
            echo     ^<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"^> >> payment\payment.html
            echo     ^<style^> >> payment\payment.html
            echo         body { padding: 40px; max-width: 800px; margin: 0 auto; } >> payment\payment.html
            echo         .header { margin-bottom: 30px; text-align: center; } >> payment\payment.html
            echo         .btn-primary { background-color: #635BFF; border-color: #635BFF; } >> payment\payment.html
            echo         .features { margin: 30px 0; } >> payment\payment.html
            echo         .feature-item { margin: 15px 0; } >> payment\payment.html
            echo     ^</style^> >> payment\payment.html
            echo ^</head^> >> payment\payment.html
            echo ^<body^> >> payment\payment.html
            echo     ^<div class="container"^> >> payment\payment.html
            echo         ^<div class="header"^> >> payment\payment.html
            echo             ^<h1^>Upgrade to Pro^</h1^> >> payment\payment.html
            echo             ^<p class="lead"^>Unlock all premium features of the extension^</p^> >> payment\payment.html
            echo         ^</div^> >> payment\payment.html
            echo. >> payment\payment.html
            echo         ^<div class="features"^> >> payment\payment.html
            echo             ^<h3^>Pro Features Include:^</h3^> >> payment\payment.html
            echo             ^<div class="feature-item"^> >> payment\payment.html
            echo                 ^<h5^>✓ Unlimited Items^</h5^> >> payment\payment.html
            echo                 ^<p^>No more 5-item limit. Add as many items as you need.^</p^> >> payment\payment.html
            echo             ^</div^> >> payment\payment.html
            echo             ^<div class="feature-item"^> >> payment\payment.html
            echo                 ^<h5^>✓ Advanced Analytics^</h5^> >> payment\payment.html
            echo                 ^<p^>Get detailed statistics and insights about your usage.^</p^> >> payment\payment.html
            echo             ^</div^> >> payment\payment.html
            echo             ^<div class="feature-item"^> >> payment\payment.html
            echo                 ^<h5^>✓ Priority Support^</h5^> >> payment\payment.html
            echo                 ^<p^>Get faster responses to your support requests.^</p^> >> payment\payment.html
            echo             ^</div^> >> payment\payment.html
            echo         ^</div^> >> payment\payment.html
            echo. >> payment\payment.html
            echo         ^<div class="text-center"^> >> payment\payment.html
            echo             ^<h3^>One-time Payment: $9.99^</h3^> >> payment\payment.html
            echo             ^<p^>Lifetime access to all Pro features^</p^> >> payment\payment.html
            echo             ^<button id="checkout-button" class="btn btn-primary btn-lg"^>Upgrade Now^</button^> >> payment\payment.html
            echo         ^</div^> >> payment\payment.html
            echo     ^</div^> >> payment\payment.html
            echo. >> payment\payment.html
            echo     ^<script src="payment.js"^>^</script^> >> payment\payment.html
            echo ^</body^> >> payment\payment.html
            echo ^</html^> >> payment\payment.html
            echo Created payment/payment.html template
        )
        
        if not exist payment\payment.js (
            echo // Stripe public key >> payment\payment.js
            echo const STRIPE_PUBLIC_KEY = 'your_stripe_public_key'; >> payment\payment.js
            echo. >> payment\payment.js
            echo // Backend server URL - change to your production URL when deploying >> payment\payment.js
            echo const BACKEND_URL = 'http://localhost:3000'; >> payment\payment.js
            echo. >> payment\payment.js
            echo document.addEventListener('DOMContentLoaded', function() { >> payment\payment.js
            echo     // Initialize checkout button >> payment\payment.js
            echo     const checkoutButton = document.getElementById('checkout-button'); >> payment\payment.js
            echo     if (checkoutButton) { >> payment\payment.js
            echo         checkoutButton.addEventListener('click', handleCheckout); >> payment\payment.js
            echo     } >> payment\payment.js
            echo }); >> payment\payment.js
            echo. >> payment\payment.js
            echo // Handle the checkout process >> payment\payment.js
            echo async function handleCheckout() { >> payment\payment.js
            echo     try { >> payment\payment.js
            echo         // Get extension ID from URL parameters >> payment\payment.js
            echo         const urlParams = new URLSearchParams(window.location.search); >> payment\payment.js
            echo         const extensionId = urlParams.get('extensionId'); >> payment\payment.js
            echo. >> payment\payment.js
            echo         // Disable the button during the request >> payment\payment.js
            echo         const button = document.getElementById('checkout-button'); >> payment\payment.js
            echo         button.disabled = true; >> payment\payment.js
            echo         button.textContent = 'Processing...'; >> payment\payment.js
            echo. >> payment\payment.js
            echo         // Create checkout session >> payment\payment.js
            echo         const response = await fetch(`${BACKEND_URL}/create-checkout-session`, { >> payment\payment.js
            echo             method: 'POST', >> payment\payment.js
            echo             headers: { >> payment\payment.js
            echo                 'Content-Type': 'application/json', >> payment\payment.js
            echo             }, >> payment\payment.js
            echo             body: JSON.stringify({ extensionId }) >> payment\payment.js
            echo         }); >> payment\payment.js
            echo. >> payment\payment.js
            echo         if (!response.ok) { >> payment\payment.js
            echo             throw new Error('Failed to create checkout session'); >> payment\payment.js
            echo         } >> payment\payment.js
            echo. >> payment\payment.js
            echo         const { sessionId } = await response.json(); >> payment\payment.js
            echo. >> payment\payment.js
            echo         // Load Stripe.js >> payment\payment.js
            echo         const stripe = Stripe(STRIPE_PUBLIC_KEY); >> payment\payment.js
            echo. >> payment\payment.js
            echo         // Redirect to Stripe Checkout >> payment\payment.js
            echo         const result = await stripe.redirectToCheckout({ >> payment\payment.js
            echo             sessionId: sessionId >> payment\payment.js
            echo         }); >> payment\payment.js
            echo. >> payment\payment.js
            echo         if (result.error) { >> payment\payment.js
            echo             console.error(result.error.message); >> payment\payment.js
            echo             alert(`Payment Error: ${result.error.message}`); >> payment\payment.js
            echo             button.disabled = false; >> payment\payment.js
            echo             button.textContent = 'Upgrade Now'; >> payment\payment.js
            echo         } >> payment\payment.js
            echo     } catch (error) { >> payment\payment.js
            echo         console.error('Error:', error); >> payment\payment.js
            echo         alert(`An error occurred: ${error.message}`); >> payment\payment.js
            echo         // Re-enable the button >> payment\payment.js
            echo         const button = document.getElementById('checkout-button'); >> payment\payment.js
            echo         button.disabled = false; >> payment\payment.js
            echo         button.textContent = 'Upgrade Now'; >> payment\payment.js
            echo     } >> payment\payment.js
            echo } >> payment\payment.js
            echo Created payment/payment.js template
        )
        
        if not exist payment\success.html (
            echo ^<!DOCTYPE html^> > payment\success.html
            echo ^<html lang="en"^> >> payment\success.html
            echo ^<head^> >> payment\success.html
            echo     ^<meta charset="UTF-8"^> >> payment\success.html
            echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> payment\success.html
            echo     ^<title^>Payment Successful^</title^> >> payment\success.html
            echo     ^<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"^> >> payment\success.html
            echo     ^<style^> >> payment\success.html
            echo         body { padding: 40px; max-width: 600px; margin: 0 auto; text-align: center; } >> payment\success.html
            echo         .success-icon { font-size: 80px; color: #4CAF50; margin: 20px 0; } >> payment\success.html
            echo         .container { margin-top: 50px; } >> payment\success.html
            echo     ^</style^> >> payment\success.html
            echo ^</head^> >> payment\success.html
            echo ^<body^> >> payment\success.html
            echo     ^<div class="container"^> >> payment\success.html
            echo         ^<div class="success-icon"^>✓^</div^> >> payment\success.html
            echo         ^<h1^>Payment Successful!^</h1^> >> payment\success.html
            echo         ^<p class="lead"^>Thank you for upgrading to Pro!^</p^> >> payment\success.html
            echo         ^<p^>Your extension has been upgraded and all premium features are now unlocked.^</p^> >> payment\success.html
            echo         ^<p^>You can close this window and continue using the extension.^</p^> >> payment\success.html
            echo         ^<button id="close-button" class="btn btn-primary mt-4"^>Close Window^</button^> >> payment\success.html
            echo     ^</div^> >> payment\success.html
            echo. >> payment\success.html
            echo     ^<script^> >> payment\success.html
            echo         // Send message to extension that payment is complete >> payment\success.html
            echo         document.addEventListener('DOMContentLoaded', function() { >> payment\success.html
            echo             // Get extension ID from URL parameters >> payment\success.html
            echo             const urlParams = new URLSearchParams(window.location.search); >> payment\success.html
            echo             const extensionId = urlParams.get('extensionId'); >> payment\success.html
            echo. >> payment\success.html
            echo             if (extensionId) { >> payment\success.html
            echo                 // Notify the extension about successful payment >> payment\success.html
            echo                 chrome.runtime.sendMessage(extensionId, { >> payment\success.html
            echo                     type: 'PAYMENT_SUCCESSFUL' >> payment\success.html
            echo                 }); >> payment\success.html
            echo             } >> payment\success.html
            echo. >> payment\success.html
            echo             // Add close button event handler >> payment\success.html
            echo             document.getElementById('close-button').addEventListener('click', function() { >> payment\success.html
            echo                 window.close(); >> payment\success.html
            echo             }); >> payment\success.html
            echo         }); >> payment\success.html
            echo     ^</script^> >> payment\success.html
            echo ^</body^> >> payment\success.html
            echo ^</html^> >> payment\success.html
            echo Created payment/success.html template
        )
        
        if not exist payment\cancel.html (
            echo ^<!DOCTYPE html^> > payment\cancel.html
            echo ^<html lang="en"^> >> payment\cancel.html
            echo ^<head^> >> payment\cancel.html
            echo     ^<meta charset="UTF-8"^> >> payment\cancel.html
            echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> payment\cancel.html
            echo     ^<title^>Payment Cancelled^</title^> >> payment\cancel.html
            echo     ^<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet"^> >> payment\cancel.html
            echo     ^<style^> >> payment\cancel.html
            echo         body { padding: 40px; max-width: 600px; margin: 0 auto; text-align: center; } >> payment\cancel.html
            echo         .cancel-icon { font-size: 80px; color: #F44336; margin: 20px 0; } >> payment\cancel.html
            echo         .container { margin-top: 50px; } >> payment\cancel.html
            echo     ^</style^> >> payment\cancel.html
            echo ^</head^> >> payment\cancel.html
            echo ^<body^> >> payment\cancel.html
            echo     ^<div class="container"^> >> payment\cancel.html
            echo         ^<div class="cancel-icon"^>×^</div^> >> payment\cancel.html
            echo         ^<h1^>Payment Cancelled^</h1^> >> payment\cancel.html
            echo         ^<p class="lead"^>Your payment process was cancelled.^</p^> >> payment\cancel.html
            echo         ^<p^>No charges were made to your account.^</p^> >> payment\cancel.html
            echo         ^<p^>You can close this window or try again.^</p^> >> payment\cancel.html
            echo         ^<button id="try-again" class="btn btn-primary mt-3"^>Try Again^</button^> >> payment\cancel.html
            echo         ^<button id="close-button" class="btn btn-secondary mt-3 ms-2"^>Close Window^</button^> >> payment\cancel.html
            echo     ^</div^> >> payment\cancel.html
            echo. >> payment\cancel.html
            echo     ^<script^> >> payment\cancel.html
            echo         document.addEventListener('DOMContentLoaded', function() { >> payment\cancel.html
            echo             // Get extension ID from URL parameters >> payment\cancel.html
            echo             const urlParams = new URLSearchParams(window.location.search); >> payment\cancel.html
            echo             const extensionId = urlParams.get('extensionId'); >> payment\cancel.html
            echo. >> payment\cancel.html
            echo             // Add try again button handler >> payment\cancel.html
            echo             document.getElementById('try-again').addEventListener('click', function() { >> payment\cancel.html
            echo                 window.location.href = `payment.html?extensionId=${extensionId}`; >> payment\cancel.html
            echo             }); >> payment\cancel.html
            echo. >> payment\cancel.html
            echo             // Add close button event handler >> payment\cancel.html
            echo             document.getElementById('close-button').addEventListener('click', function() { >> payment\cancel.html
            echo                 window.close(); >> payment\cancel.html
            echo             }); >> payment\cancel.html
            echo         }); >> payment\cancel.html
            echo     ^</script^> >> payment\cancel.html
            echo ^</body^> >> payment\cancel.html
            echo ^</html^> >> payment\cancel.html
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
            echo { > server\package.json
            echo   "name": "stripe-payment-server", >> server\package.json
            echo   "version": "1.0.0", >> server\package.json
            echo   "description": "Backend server for Stripe payments in Chrome extension", >> server\package.json
            echo   "main": "server.js", >> server\package.json
            echo   "scripts": { >> server\package.json
            echo     "start": "node server.js", >> server\package.json
            echo     "dev": "nodemon server.js" >> server\package.json
            echo   }, >> server\package.json
            echo   "keywords": ["stripe", "payments", "chrome-extension"], >> server\package.json
            echo   "author": "", >> server\package.json
            echo   "license": "MIT", >> server\package.json
            echo   "dependencies": { >> server\package.json
            echo     "cors": "^2.8.5", >> server\package.json
            echo     "dotenv": "^16.0.3", >> server\package.json
            echo     "express": "^4.18.2", >> server\package.json
            echo     "stripe": "^12.1.1" >> server\package.json
            echo   }, >> server\package.json
            echo   "devDependencies": { >> server\package.json
            echo     "nodemon": "^2.0.22" >> server\package.json
            echo   } >> server\package.json
            echo } >> server\package.json
            echo Created server/package.json template
        )
        
        if not exist server\server.js (
            echo // Load environment variables >> server\server.js
            echo require('dotenv').config(); >> server\server.js
            echo. >> server\server.js
            echo const express = require('express'); >> server\server.js
            echo const cors = require('cors'); >> server\server.js
            echo const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY); >> server\server.js
            echo. >> server\server.js
            echo const app = express(); >> server\server.js
            echo const port = process.env.PORT || 3000; >> server\server.js
            echo. >> server\server.js
            echo // Middleware >> server\server.js
            echo app.use(express.json()); >> server\server.js
            echo. >> server\server.js
            echo // Configure CORS >> server\server.js
            echo const allowedOrigins = process.env.ALLOWED_ORIGINS ? >> server\server.js
            echo   process.env.ALLOWED_ORIGINS.split(',') : []; >> server\server.js
            echo. >> server\server.js
            echo app.use(cors({ >> server\server.js
            echo   origin: function(origin, callback) { >> server\server.js
            echo     // Allow requests with no origin (like mobile apps, curl, etc) >> server\server.js
            echo     if (!origin) return callback(null, true); >> server\server.js
            echo     if (allowedOrigins.indexOf(origin) === -1) { >> server\server.js
            echo       const msg = 'The CORS policy for this site does not allow access from the specified Origin.'; >> server\server.js
            echo       return callback(new Error(msg), false); >> server\server.js
            echo     } >> server\server.js
            echo     return callback(null, true); >> server\server.js
            echo   } >> server\server.js
            echo })); >> server\server.js
            echo. >> server\server.js
            echo // Routes >> server\server.js
            echo app.get('/', (req, res) => { >> server\server.js
            echo   res.send('Stripe payment server is running'); >> server\server.js
            echo }); >> server\server.js
            echo. >> server\server.js
            echo // Create checkout session >> server\server.js
            echo app.post('/create-checkout-session', async (req, res) => { >> server\server.js
            echo   try { >> server\server.js
            echo     const { extensionId } = req.body; >> server\server.js
            echo. >> server\server.js
            echo     if (!extensionId) { >> server\server.js
            echo       return res.status(400).json({ error: 'Extension ID is required' }); >> server\server.js
            echo     } >> server\server.js
            echo. >> server\server.js
            echo     const session = await stripe.checkout.sessions.create({ >> server\server.js
            echo       payment_method_types: ['card'], >> server\server.js
            echo       line_items: [ >> server\server.js
            echo         { >> server\server.js
            echo           price: process.env.STRIPE_PRICE_ID, >> server\server.js
            echo           quantity: 1, >> server\server.js
            echo         }, >> server\server.js
            echo       ], >> server\server.js
            echo       mode: 'payment', >> server\server.js
            echo       success_url: `${req.headers.origin}/payment/success.html?session_id={CHECKOUT_SESSION_ID}&extensionId=${extensionId}`, >> server\server.js
            echo       cancel_url: `${req.headers.origin}/payment/cancel.html?extensionId=${extensionId}`, >> server\server.js
            echo       client_reference_id: extensionId, >> server\server.js
            echo       metadata: { >> server\server.js
            echo         extensionId: extensionId >> server\server.js
            echo       } >> server\server.js
            echo     }); >> server\server.js
            echo. >> server\server.js
            echo     res.json({ sessionId: session.id }); >> server\server.js
            echo   } catch (error) { >> server\server.js
            echo     console.error('Error creating checkout session:', error); >> server\server.js
            echo     res.status(500).json({ error: error.message }); >> server\server.js
            echo   } >> server\server.js
            echo }); >> server\server.js
            echo. >> server\server.js
            echo // Webhook endpoint >> server\server.js
            echo app.post('/webhook', express.raw({type: 'application/json'}), async (req, res) => { >> server\server.js
            echo   const sig = req.headers['stripe-signature']; >> server\server.js
            echo. >> server\server.js
            echo   let event; >> server\server.js
            echo. >> server\server.js
            echo   try { >> server\server.js
            echo     event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET); >> server\server.js
            echo   } catch (err) { >> server\server.js
            echo     console.error(`Webhook Error: ${err.message}`); >> server\server.js
            echo     return res.status(400).send(`Webhook Error: ${err.message}`); >> server\server.js
            echo   } >> server\server.js
            echo. >> server\server.js
            echo   // Handle the event >> server\server.js
            echo   switch (event.type) { >> server\server.js
            echo     case 'checkout.session.completed': >> server\server.js
            echo       const session = event.data.object; >> server\server.js
            echo       // Here you would typically update a database to mark the user as paid >> server\server.js
            echo       console.log(`Payment successful for extension: ${session.metadata.extensionId}`); >> server\server.js
            echo       break; >> server\server.js
            echo     case 'payment_intent.payment_failed': >> server\server.js
            echo       const paymentIntent = event.data.object; >> server\server.js
            echo       console.log(`Payment failed: ${paymentIntent.last_payment_error?.message}`); >> server\server.js
            echo       break; >> server\server.js
            echo     default: >> server\server.js
            echo       console.log(`Unhandled event type ${event.type}`); >> server\server.js
            echo   } >> server\server.js
            echo. >> server\server.js
            echo   // Return a 200 response to acknowledge receipt of the event >> server\server.js
            echo   res.send(); >> server\server.js
            echo }); >> server\server.js
            echo. >> server\server.js
            echo // Check payment status >> server\server.js
            echo app.get('/check-payment/:sessionId', async (req, res) => { >> server\server.js
            echo   try { >> server\server.js
            echo     const { sessionId } = req.params; >> server\server.js
            echo     const session = await stripe.checkout.sessions.retrieve(sessionId); >> server\server.js
            echo. >> server\server.js
            echo     if (session && session.payment_status === 'paid') { >> server\server.js
            echo       res.json({ paid: true }); >> server\server.js
            echo     } else { >> server\server.js
            echo       res.json({ paid: false }); >> server\server.js
            echo     } >> server\server.js
            echo   } catch (error) { >> server\server.js
            echo     console.error('Error checking payment status:', error); >> server\server.js
            echo     res.status(500).json({ error: error.message }); >> server\server.js
            echo   } >> server\server.js
            echo }); >> server\server.js
            echo. >> server\server.js
            echo // Start server >> server\server.js
            echo app.listen(port, () => { >> server\server.js
            echo   console.log(`Server running on port ${port}`); >> server\server.js
            echo   console.log(`Allowed origins: ${allowedOrigins.join(', ')}`); >> server\server.js
            echo }); >> server\server.js
            echo Created server/server.js template
        )
        
        if not exist server\.env.example (
            echo # Stripe API Keys >> server\.env.example
            echo STRIPE_SECRET_KEY=sk_test_your_test_key >> server\.env.example
            echo STRIPE_PRICE_ID=price_your_price_id >> server\.env.example
            echo STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret >> server\.env.example
            echo. >> server\.env.example
            echo # Server Configuration >> server\.env.example
            echo PORT=3000 >> server\.env.example
            echo. >> server\.env.example
            echo # Security >> server\.env.example
            echo # Comma-separated list of allowed origins (e.g., chrome-extension://your-extension-id) >> server\.env.example
            echo ALLOWED_ORIGINS=chrome-extension://your-extension-id >> server\.env.example
            echo Created server/.env.example template
        )
        
        if not exist server\README.md (
            echo # Stripe Payment Server for Chrome Extension >> server\README.md
            echo. >> server\README.md
            echo This is a backend server for handling Stripe payments in your Chrome extension. >> server\README.md
            echo. >> server\README.md
            echo ## Setup >> server\README.md
            echo. >> server\README.md
            echo 1. Install dependencies: >> server\README.md
            echo    ```bash >> server\README.md
            echo    npm install >> server\README.md
            echo    ``` >> server\README.md
            echo. >> server\README.md
            echo 2. Create .env file: >> server\README.md
            echo    ```bash >> server\README.md
            echo    cp .env.example .env >> server\README.md
            echo    ``` >> server\README.md
            echo. >> server\README.md
            echo 3. Update .env with your Stripe credentials: >> server\README.md
            echo    - STRIPE_SECRET_KEY: Your Stripe secret key >> server\README.md
            echo    - STRIPE_PRICE_ID: The ID of your product price >> server\README.md
            echo    - STRIPE_WEBHOOK_SECRET: Your Stripe webhook secret >> server\README.md
            echo    - ALLOWED_ORIGINS: Your Chrome extension ID (format: chrome-extension://your-extension-id) >> server\README.md
            echo. >> server\README.md
            echo 4. Run the server: >> server\README.md
            echo    ```bash >> server\README.md
            echo    # Development >> server\README.md
            echo    npm run dev >> server\README.md
            echo. >> server\README.md
            echo    # Production >> server\README.md
            echo    npm start >> server\README.md
            echo    ``` >> server\README.md
            echo. >> server\README.md
            echo ## Endpoints >> server\README.md
            echo. >> server\README.md
            echo - `POST /create-checkout-session`: Creates a Stripe checkout session >> server\README.md
            echo - `POST /webhook`: Receives Stripe webhook events >> server\README.md
            echo - `GET /check-payment/:sessionId`: Checks payment status for a session ID >> server\README.md
            echo. >> server\README.md
            echo ## Production Deployment >> server\README.md
            echo. >> server\README.md
            echo For production, deploy this server to a hosting service like Heroku, Vercel, or AWS. >> server\README.md
            echo Make sure to: >> server\README.md
            echo. >> server\README.md
            echo 1. Set environment variables on your hosting platform >> server\README.md
            echo 2. Update Stripe webhook endpoints to point to your production URL >> server\README.md
            echo 3. Update the BACKEND_URL in your extension's payment.js file >> server\README.md
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
    npm install nodemon --save-dev
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
        echo PORT=3000 >> server\.env
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
echo.
echo 1. Log into your Stripe dashboard at https://dashboard.stripe.com
echo.
echo 2. Create a one-time payment product:
echo    - Go to Products ^> Add Product
echo    - Name your product (e.g., "Chrome Extension Pro")
echo    - Add description (e.g., "Unlock all premium features")
echo    - Set a price (e.g., $9.99)
echo    - Select "One time" payment
echo    - Save the product
echo    - Note the Price ID (starts with "price_")
echo.
echo 3. Get your API keys:
echo    - Go to Developers ^> API keys
echo    - Note your publishable key (starts with "pk_")
echo    - Note your secret key (starts with "sk_")
echo    - Use test keys for development, live keys for production
echo.
echo 4. Set up webhook (for production):
echo    - Go to Developers ^> Webhooks
echo    - Add endpoint URL (your server URL + "/webhook")
echo    - Select events: checkout.session.completed, payment_intent.payment_failed
echo    - Get the webhook signing secret (starts with "whsec_")
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
        echo PORT=3000 >> server\.env
        echo .env file updated!
    )
    
    echo.
    echo Do you want to update payment.js with your publishable key?
    set /p update_js=Update payment.js? (Y/N): 
    if /i "!update_js!"=="Y" (
        if exist payment\payment.js (
            echo Updating payment.js...
            
            set "search=const STRIPE_PUBLIC_KEY = 'your_stripe_public_key';"
            set "replace=const STRIPE_PUBLIC_KEY = '!stripe_pub!';"
            
            set "tempfile=%temp%\tempfile.txt"
            
            if exist "!tempfile!" del "!tempfile!"
            
            for /f "tokens=1,* delims=¶" %%A in ('type "payment\payment.js"^|find /n /v ""^|findstr /r ".*"^|replace.exe /r "[0-9]*:" "" /') do (
                set "line=%%B"
                set "newline=!line:%search%=%replace%!"
                echo(!newline!>> "!tempfile!"
            )
            
            copy "!tempfile!" "payment\payment.js" > nul
            del "!tempfile!"
            
            echo payment.js updated with your Stripe public key!
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
echo 2. payment/payment.js - Stripe public key and backend URL
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
        echo PORT=3000 >> server\.env
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
    echo And the correct backend URL:
    echo const BACKEND_URL = 'http://localhost:3000';
    echo.
    echo Do you need to update these settings?
    set /p correct_js=Update payment.js settings? (Y/N): 
    if /i "!correct_js!"=="Y" (
        echo.
        set /p stripe_pub=Enter your Stripe publishable key: 
        set /p backend_url=Enter your backend URL (default: http://localhost:3000): 
        
        if "!backend_url!"=="" set "backend_url=http://localhost:3000"
        
        echo.
        echo Updating payment.js...
        
        set "search_key=const STRIPE_PUBLIC_KEY = '.*';"
        set "replace_key=const STRIPE_PUBLIC_KEY = '!stripe_pub!';"
        
        set "search_url=const BACKEND_URL = '.*';"
        set "replace_url=const BACKEND_URL = '!backend_url!';"
        
        set "tempfile=%temp%\tempfile.txt"
        
        if exist "!tempfile!" del "!tempfile!"
        
        powershell -Command "(Get-Content payment\payment.js) -replace \"const STRIPE_PUBLIC_KEY = '.*';\", \"const STRIPE_PUBLIC_KEY = '!stripe_pub!';\" -replace \"const BACKEND_URL = '.*';\", \"const BACKEND_URL = '!backend_url!';\" | Set-Content payment\payment.js.new"
        
        move /y payment\payment.js.new payment\payment.js > nul
        
        echo payment.js updated with your settings!
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
echo.
echo Add these permissions to your manifest.json:
echo.
echo   "permissions": [
echo     "storage",
echo     "identity"
echo   ],
echo.
echo Add content security policy:
echo.
echo   "content_security_policy": {
echo     "extension_pages": "script-src 'self' https://js.stripe.com; object-src 'self'"
echo   },
echo.
echo Add web_accessible_resources for payment-related files:
echo.
echo   "web_accessible_resources": [{
echo     "resources": ["payment/*"],
echo     "matches": ["<all_urls>"]
echo   }],
echo.
echo Do you want to update your manifest.json?
set /p update_manifest=Update manifest.json? (Y/N): 
if /i "%update_manifest%"=="Y" (
    if exist manifest.json (
        echo.
        echo Please make the following changes to your manifest.json file:
        echo 1. Add "storage" and "identity" to permissions
        echo 2. Add content_security_policy as shown above
        echo 3. Add web_accessible_resources for payment files
        echo.
        echo Would you like to open manifest.json in Notepad to edit it?
        set /p open_manifest=Open manifest.json? (Y/N): 
        if /i "!open_manifest!"=="Y" (
            start notepad manifest.json
        )
    ) else (
        echo.
        echo manifest.json not found. Do you want to create a basic manifest.json?
        set /p create_manifest=Create manifest.json? (Y/N): 
        if /i "!create_manifest!"=="Y" (
            echo { > manifest.json
            echo   "manifest_version": 3, >> manifest.json
            echo   "name": "My Extension with Stripe Payments", >> manifest.json
            echo   "version": "1.0.0", >> manifest.json
            echo   "description": "A Chrome extension with Stripe payment integration", >> manifest.json
            echo   "action": { >> manifest.json
            echo     "default_popup": "popup.html", >> manifest.json
            echo     "default_icon": { >> manifest.json
            echo       "16": "images/icon16.png", >> manifest.json
            echo       "48": "images/icon48.png", >> manifest.json
            echo       "128": "images/icon128.png" >> manifest.json
            echo     } >> manifest.json
            echo   }, >> manifest.json
            echo   "background": { >> manifest.json
            echo     "service_worker": "background.js" >> manifest.json
            echo   }, >> manifest.json
            echo   "permissions": [ >> manifest.json
            echo     "storage", >> manifest.json
            echo     "identity" >> manifest.json
            echo   ], >> manifest.json
            echo   "content_security_policy": { >> manifest.json
            echo     "extension_pages": "script-src 'self' https://js.stripe.com; object-src 'self'" >> manifest.json
            echo   }, >> manifest.json
            echo   "web_accessible_resources": [{ >> manifest.json
            echo     "resources": ["payment/*"], >> manifest.json
            echo     "matches": ["<all_urls>"] >> manifest.json
            echo   }] >> manifest.json
            echo } >> manifest.json
            echo Basic manifest.json created!
        )
    )
)

echo.
echo BACKGROUND.JS CHANGES:
echo.
echo Add functions for:
echo - Checking payment status on extension load
echo - Storing payment status after successful payment
echo - Limiting features based on payment status
echo.
echo Do you want to update your background.js?
set /p update_bg=Update background.js? (Y/N): 
if /i "%update_bg%"=="Y" (
    if exist background.js (
        echo.
        echo Please make the following additions to your background.js file:
        echo.
        echo 1. Add storage functions for payment status
        echo 2. Add message listeners for payment events
        echo 3. Add feature limitation functions
        echo.
        echo Would you like to open background.js in Notepad to edit it?
        set /p open_bg=Open background.js? (Y/N): 
        if /i "!open_bg!"=="Y" (
            start notepad background.js
        )
    ) else (
        echo.
        echo background.js not found. Do you want to create a basic background.js?
        set /p create_bg=Create background.js? (Y/N): 
        if /i "!create_bg!"=="Y" (
            echo // Background service worker for handling payments >> background.js
            echo. >> background.js
            echo // Initialize payment status on extension installation >> background.js
            echo chrome.runtime.onInstalled.addListener(async () => { >> background.js
            echo   await chrome.storage.local.set({ isPremium: false }); >> background.js
            echo   console.log('Extension installed, premium status set to false'); >> background.js
            echo }); >> background.js
            echo. >> background.js
            echo // Check payment status >> background.js
            echo async function checkPaymentStatus() { >> background.js
            echo   const data = await chrome.storage.local.get('isPremium'); >> background.js
            echo   return data.isPremium === true; >> background.js
            echo } >> background.js
            echo. >> background.js
            echo // Set premium status >> background.js
            echo async function setPremiumStatus(isPremium) { >> background.js
            echo   await chrome.storage.local.set({ isPremium }); >> background.js
            echo   console.log(`Premium status set to ${isPremium}`); >> background.js
            echo   // Notify all open extension pages about the status change >> background.js
            echo   chrome.runtime.sendMessage({ type: 'PREMIUM_STATUS_CHANGED', isPremium }); >> background.js
            echo } >> background.js
            echo. >> background.js
            echo // Feature limitation function - an example >> background.js
            echo async function checkFeatureAvailability(featureType) { >> background.js
            echo   const isPremium = await checkPaymentStatus(); >> background.js
            echo. >> background.js
            echo   if (featureType === 'basic') { >> background.js
            echo     return true; // Basic features always available >> background.js
            echo   } else if (featureType === 'item_count') { >> background.js
            echo     // Get current items >> background.js
            echo     const data = await chrome.storage.local.get('items'); >> background.js
            echo     const items = data.items || []; >> background.js
            echo     // Free users limited to 5 items >> background.js
            echo     return isPremium || items.length < 5; >> background.js
            echo   } else if (featureType === 'premium') { >> background.js
            echo     return isPremium; // Premium features only for paid users >> background.js
            echo   } >> background.js
            echo. >> background.js
            echo   return false; >> background.js
            echo } >> background.js
            echo. >> background.js
            echo // Listen for messages from content scripts or popup >> background.js
            echo chrome.runtime.onMessage.addListener((message, sender, sendResponse) => { >> background.js
            echo   if (message.type === 'CHECK_PREMIUM_STATUS') { >> background.js
            echo     checkPaymentStatus().then(isPremium => { >> background.js
            echo       sendResponse({ isPremium }); >> background.js
            echo     }); >> background.js
            echo     return true; // Indicates we will send a response asynchronously >> background.js
            echo   } >> background.js
            echo. >> background.js
            echo   if (message.type === 'CHECK_FEATURE_AVAILABILITY') { >> background.js
            echo     checkFeatureAvailability(message.featureType).then(isAvailable => { >> background.js
            echo       sendResponse({ isAvailable }); >> background.js
            echo     }); >> background.js
            echo     return true; >> background.js
            echo   } >> background.js
            echo. >> background.js
            echo   if (message.type === 'PAYMENT_SUCCESSFUL') { >> background.js
            echo     console.log('Payment successful message received'); >> background.js
            echo     setPremiumStatus(true).then(() => { >> background.js
            echo       sendResponse({ success: true }); >> background.js
            echo     }); >> background.js
            echo     return true; >> background.js
            echo   } >> background.js
            echo }); >> background.js
            echo. >> background.js
            echo // External message handling (from payment pages) >> background.js
            echo chrome.runtime.onMessageExternal.addListener((message, sender, sendResponse) => { >> background.js
            echo   if (message.type === 'PAYMENT_SUCCESSFUL') { >> background.js
            echo     console.log('External payment successful message received'); >> background.js
            echo     setPremiumStatus(true).then(() => { >> background.js
            echo       sendResponse({ success: true }); >> background.js
            echo     }); >> background.js
            echo     return true; >> background.js
            echo   } >> background.js
            echo }); >> background.js
            echo Basic background.js created!
        )
    )
)

echo.
echo POPUP.JS CHANGES:
echo.
echo Add code for:
echo - Displaying premium UI elements
echo - Handling "Upgrade to Pro" button clicks
echo - Opening payment page when upgrade button is clicked
echo - Refreshing UI based on payment status
echo.
echo Do you want to update your popup.js?
set /p update_popup=Update popup.js? (Y/N): 
if /i "%update_popup%"=="Y" (
    if exist popup.js (
        echo.
        echo Please make the following additions to your popup.js file:
        echo.
        echo 1. Add UI update functions based on premium status
        echo 2. Add upgrade button click handler
        echo 3. Add premium status check on popup load
        echo.
        echo Would you like to open popup.js in Notepad to edit it?
        set /p open_popup=Open popup.js? (Y/N): 
        if /i "!open_popup!"=="Y" (
            start notepad popup.js
        )
    ) else (
        echo.
        echo popup.js not found. Do you want to create a basic popup.js?
        set /p create_popup=Create popup.js? (Y/N): 
        if /i "!create_popup!"=="Y" (
            echo // Popup script for handling UI and payment flow >> popup.js
            echo. >> popup.js
            echo document.addEventListener('DOMContentLoaded', function() { >> popup.js
            echo   // Initialize UI >> popup.js
            echo   updateUI(); >> popup.js
            echo. >> popup.js
            echo   // Add event listeners >> popup.js
            echo   const upgradeButton = document.getElementById('upgrade-button'); >> popup.js
            echo   if (upgradeButton) { >> popup.js
            echo     upgradeButton.addEventListener('click', handleUpgradeClick); >> popup.js
            echo   } >> popup.js
            echo. >> popup.js
            echo   // Listen for premium status changes >> popup.js
            echo   chrome.runtime.onMessage.addListener((message) => { >> popup.js
            echo     if (message.type === 'PREMIUM_STATUS_CHANGED') { >> popup.js
            echo       updateUI(); >> popup.js
            echo     } >> popup.js
            echo   }); >> popup.js
            echo }); >> popup.js
            echo. >> popup.js
            echo // Update UI based on premium status >> popup.js
            echo async function updateUI() { >> popup.js
            echo   const { isPremium } = await chrome.runtime.sendMessage({ type: 'CHECK_PREMIUM_STATUS' }); >> popup.js
            echo. >> popup.js
            echo   // Update upgrade button visibility >> popup.js
            echo   const upgradeButton = document.getElementById('upgrade-button'); >> popup.js
            echo   if (upgradeButton) { >> popup.js
            echo     upgradeButton.style.display = isPremium ? 'none' : 'block'; >> popup.js
            echo   } >> popup.js
            echo. >> popup.js
            echo   // Update premium features visibility >> popup.js
            echo   const premiumFeatures = document.querySelectorAll('.premium-feature'); >> popup.js
            echo   premiumFeatures.forEach(element => { >> popup.js
            echo     element.style.display = isPremium ? 'block' : 'none'; >> popup.js
            echo   }); >> popup.js
            echo. >> popup.js
            echo   // Update premium badge visibility >> popup.js
            echo   const premiumBadge = document.getElementById('premium-badge'); >> popup.js
            echo   if (premiumBadge) { >> popup.js
            echo     premiumBadge.style.display = isPremium ? 'block' : 'none'; >> popup.js
            echo   } >> popup.js
            echo. >> popup.js
            echo   // Update free tier limitations message >> popup.js
            echo   const freeTierMessage = document.getElementById('free-tier-message'); >> popup.js
            echo   if (freeTierMessage) { >> popup.js
            echo     freeTierMessage.style.display = isPremium ? 'none' : 'block'; >> popup.js
            echo   } >> popup.js
            echo. >> popup.js
            echo   // Check item limit for free tier >> popup.js
            echo   if (!isPremium) { >> popup.js
            echo     const { isAvailable } = await chrome.runtime.sendMessage({ >> popup.js
            echo       type: 'CHECK_FEATURE_AVAILABILITY', >> popup.js
            echo       featureType: 'item_count' >> popup.js
            echo     }); >> popup.js
            echo. >> popup.js
            echo     const addItemButton = document.getElementById('add-item-button'); >> popup.js
            echo     if (addItemButton) { >> popup.js
            echo       addItemButton.disabled = !isAvailable; >> popup.js
            echo     } >> popup.js
            echo. >> popup.js
            echo     const itemLimitMessage = document.getElementById('item-limit-message'); >> popup.js
            echo     if (itemLimitMessage) { >> popup.js
            echo       itemLimitMessage.style.display = isAvailable ? 'none' : 'block'; >> popup.js
            echo     } >> popup.js
            echo   } >> popup.js
            echo } >> popup.js
            echo. >> popup.js
            echo // Handle upgrade button click >> popup.js
            echo function handleUpgradeClick() { >> popup.js
            echo   // Get extension ID >> popup.js
            echo   const extensionId = chrome.runtime.id; >> popup.js
            echo. >> popup.js
            echo   // Create payment page URL >> popup.js
            echo   const paymentUrl = chrome.runtime.getURL(`payment/payment.html?extensionId=${extensionId}`); >> popup.js
            echo. >> popup.js
            echo   // Open payment page in a new tab >> popup.js
            echo   chrome.tabs.create({ url: paymentUrl }); >> popup.js
            echo } >> popup.js
            echo Basic popup.js created!
        )
        
        echo.
        echo Do you also want to create a basic popup.html?
        set /p create_popup_html=Create popup.html? (Y/N): 
        if /i "!create_popup_html!"=="Y" (
            echo ^<!DOCTYPE html^> > popup.html
            echo ^<html lang="en"^> >> popup.html
            echo ^<head^> >> popup.html
            echo     ^<meta charset="UTF-8"^> >> popup.html
            echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^> >> popup.html
            echo     ^<title^>Extension Popup^</title^> >> popup.html
            echo     ^<style^> >> popup.html
            echo         body { width: 300px; padding: 10px; font-family: Arial, sans-serif; } >> popup.html
            echo         .container { margin-bottom: 15px; } >> popup.html
            echo         button { margin-top: 10px; padding: 8px 12px; cursor: pointer; } >> popup.html
            echo         #upgrade-button { background-color: #635BFF; color: white; border: none; border-radius: 4px; } >> popup.html
            echo         .premium-feature { display: none; } >> popup.html
            echo         #premium-badge { display: none; background-color: gold; color: black; padding: 2px 6px; border-radius: 4px; } >> popup.html
            echo         #item-limit-message { color: red; font-size: 12px; margin-top: 5px; display: none; } >> popup.html
            echo         #free-tier-message { font-size: 12px; color: #666; } >> popup.html
            echo     ^</style^> >> popup.html
            echo ^</head^> >> popup.html
            echo ^<body^> >> popup.html
            echo     ^<div class="container"^> >> popup.html
            echo         ^<h1^>My Extension^</h1^> >> popup.html
            echo         ^<span id="premium-badge"^>PRO^</span^> >> popup.html
            echo     ^</div^> >> popup.html
            echo. >> popup.html
            echo     ^<div class="container"^> >> popup.html
            echo         ^<h3^>Features^</h3^> >> popup.html
            echo         ^<div^> >> popup.html
            echo             ^<p^>Basic Feature 1^</p^> >> popup.html
            echo             ^<p^>Basic Feature 2^</p^> >> popup.html
            echo         ^</div^> >> popup.html
            echo         ^<div class="premium-feature"^> >> popup.html
            echo             ^<p^>Premium Feature 1^</p^> >> popup.html
            echo             ^<p^>Premium Feature 2^</p^> >> popup.html
            echo         ^</div^> >> popup.html
            echo     ^</div^> >> popup.html
            echo. >> popup.html
            echo     ^<div class="container"^> >> popup.html
            echo         ^<h3^>Items^</h3^> >> popup.html
            echo         ^<div id="items-list"^> >> popup.html
            echo             ^<!-- Items will be loaded here --^> >> popup.html
            echo         ^</div^> >> popup.html
            echo         ^<button id="add-item-button"^>Add Item^</button^> >> popup.html
            echo         ^<p id="item-limit-message"^>Free tier limited to 5 items. Upgrade to Pro for unlimited items.^</p^> >> popup.html
            echo     ^</div^> >> popup.html
            echo. >> popup.html
            echo     ^<div id="free-tier-message"