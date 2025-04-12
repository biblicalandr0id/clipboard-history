# Clipboard History Extension Server

This is the backend server for the Clipboard History Chrome extension, handling Stripe payment integration.

## Setup Instructions

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your actual values:
# - Add your Stripe secret key
# - Add your Stripe price ID
# - Update the ALLOWED_ORIGINS with your extension ID
```

3. Set up Stripe webhook:
- Go to your Stripe Dashboard
- Navigate to Developers > Webhooks
- Add a new webhook endpoint: `https://your-domain.com/webhook`
- Add the webhook secret to your `.env` file

4. Start the server:
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

## Security Features

- CORS protection with allowed origins
- Rate limiting to prevent abuse
- Security headers
- Webhook signature verification
- Error handling and logging
- No sensitive data exposure in production

## API Endpoints

### POST /create-checkout-session
Creates a new Stripe checkout session for one-time payment.

### POST /webhook
Handles Stripe webhook events for payment confirmation.

## Environment Variables

- `STRIPE_SECRET_KEY`: Your Stripe secret key
- `STRIPE_PRICE_ID`: ID of your product's price in Stripe
- `STRIPE_WEBHOOK_SECRET`: Webhook signing secret from Stripe
- `PORT`: Server port (default: 3000)
- `ALLOWED_ORIGINS`: Comma-separated list of allowed extension IDs
