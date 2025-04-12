// Stripe payment integration
const STRIPE_PUBLIC_KEY = 'pk_live_51QTwrqKTX3OkG928RCmsxo7d5Oad33tfVgYSZEDiwJFlX4FEeZXHVifrRLE1ReJqkRf9OCybC74NGxtCD7dPgNwd00WWTDGMSd';
const SERVER_URL = process.env.NODE_ENV === 'production' 
    ? 'https://clipboard-history-server.onrender.com'  // Production URL on Render
    : 'http://localhost:3000'; // Local development URL

// Initialize Stripe
let stripe;

// Payment status management
async function checkPaymentStatus() {
    try {
        const { isPaid } = await chrome.storage.sync.get(['isPaid']);
        return isPaid === true;
    } catch (error) {
        console.error('Error checking payment status:', error);
        return false;
    }
}

// Initialize payment system
async function initializePayment() {
    try {
        if (!stripe) {
            stripe = Stripe(STRIPE_PUBLIC_KEY);
        }
        const isPaid = await checkPaymentStatus();
        if (isPaid) {
            const purchaseBtn = document.getElementById('purchaseBtn');
            if (purchaseBtn) {
                purchaseBtn.disabled = true;
                purchaseBtn.textContent = 'Already Purchased';
            }
        }
    } catch (error) {
        console.error('Error initializing Stripe:', error);
        throw error;
    }
}

// Create payment session
async function createPaymentSession() {
    try {
        const response = await fetch(`${SERVER_URL}/create-checkout-session`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || 'Failed to create checkout session');
        }

        const session = await response.json();
        
        if (session.error) {
            throw new Error(session.error);
        }

        const result = await stripe.redirectToCheckout({
            sessionId: session.id
        });

        if (result.error) {
            throw new Error(result.error.message);
        }
    } catch (error) {
        console.error('Error creating payment session:', error);
        // Show user-friendly error message
        const errorMessage = error.message || 'Failed to start checkout process. Please try again later.';
        alert(errorMessage);
        throw error; // Re-throw for the calling code to handle
    }
}

// Handle successful payment
async function handlePaymentSuccess() {
    try {
        await chrome.storage.sync.set({ isPaid: true });
        
        // Notify background script about successful payment
        chrome.runtime.sendMessage({ 
            action: 'paymentSuccess',
            timestamp: Date.now()
        });

        // Update UI if we're on the payment page
        const purchaseBtn = document.getElementById('purchaseBtn');
        if (purchaseBtn) {
            purchaseBtn.disabled = true;
            purchaseBtn.textContent = 'Already Purchased';
        }

        return true;
    } catch (error) {
        console.error('Error updating payment status:', error);
        return false;
    }
}

// Export functions
window.paymentSystem = {
    checkPaymentStatus,
    initializePayment,
    createPaymentSession,
    handlePaymentSuccess,
};
