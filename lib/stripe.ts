import Stripe from "stripe";

// Conditional Stripe client initialization for build time
export const stripe = process.env.STRIPE_SECRET_KEY 
  ? new Stripe(process.env.STRIPE_SECRET_KEY, { 
      apiVersion: "2025-02-24.acacia" 
    })
  : null;

export const STRIPE_PRICE_PRO = process.env.STRIPE_PRICE_PRO!
