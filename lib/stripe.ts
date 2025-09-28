let stripe: any = null;

// Only initialize Stripe when we have the necessary environment variables
if (process.env.STRIPE_SECRET_KEY) {
  try {
    const Stripe = require("stripe");
    stripe = new Stripe(process.env.STRIPE_SECRET_KEY, { 
      apiVersion: "2025-02-24.acacia" 
    });
  } catch (error) {
    console.warn('Stripe could not be initialized:', error);
  }
}

export { stripe };
export const STRIPE_PRICE_PRO = process.env.STRIPE_PRICE_PRO || "";
