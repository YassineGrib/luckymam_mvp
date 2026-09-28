import crypto from "crypto";
import admin from "firebase-admin";
import { onRequest } from "firebase-functions/v2/https";

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Chargily Pay V2 API URLs & Secret Key
const CHARGILY_SECRET_KEY =
  process.env.CHARGILY_SECRET_KEY ||
  "test_sk_jvafVLt72Jkk8DIepElTKJLEANXnDxctuMEZHFYA";

const CHARGILY_API_URL = CHARGILY_SECRET_KEY.startsWith("test_sk_")
  ? "https://pay.chargily.net/test/api/v2"
  : "https://pay.chargily.net/api/v2";

/**
 * 1. Create Checkout Session
 * Called by the Flutter mobile or web client to initialize a payment session.
 */
export const createChargilyCheckout = onRequest(
  {
    region: "us-central1",
    cors: true,
  },
  async (req, res) => {
    // Only allow POST
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed. Use POST." });
      return;
    }

    try {
      const {
        amount,
        userId,
        type = "subscription", // 'subscription' or 'order'
        planTier,
        orderId,
        customerName,
        customerEmail,
        customerPhone,
        successUrl = "https://luckymam-app-dv.web.app/#/payment-success",
        failureUrl = "https://luckymam-app-dv.web.app/#/payment-failure",
      } = req.body;

      if (!amount || amount <= 0) {
        res.status(400).json({ error: "Invalid amount. Must be greater than 0." });
        return;
      }

      if (!userId) {
        res.status(400).json({ error: "Missing required field: userId." });
        return;
      }

      // Metadata for Webhook processing
      const metadata = {
        userId,
        type,
        ...(planTier && { planTier }),
        ...(orderId && { orderId }),
        timestamp: new Date().toISOString(),
      };

      // Call Chargily Pay V2 checkouts API
      const chargilyPayload = {
        amount: Number(amount),
        currency: "dzd",
        success_url: successUrl,
        failure_url: failureUrl,
        locale: "ar",
        metadata,
      };

      const response = await fetch(`${CHARGILY_API_URL}/checkouts`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${CHARGILY_SECRET_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(chargilyPayload),
      });

      const data = await response.json();

      if (!response.ok) {
        console.error("[createChargilyCheckout] Error from Chargily API:", data);
        res.status(response.status).json({
          error: data.message || "Failed to create checkout session with Chargily.",
          details: data,
        });
        return;
      }

      // Store pending transaction record in Firestore
      await db.collection("payment_transactions").doc(data.id).set({
        checkoutId: data.id,
        userId,
        type,
        amount,
        currency: "dzd",
        status: "pending",
        checkoutUrl: data.checkout_url,
        metadata,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({
        success: true,
        checkoutId: data.id,
        checkoutUrl: data.checkout_url,
      });
    } catch (error) {
      console.error("[createChargilyCheckout] Internal Error:", error);
      res.status(500).json({
        error: "Internal server error creating payment session.",
        message: error.message,
      });
    }
  },
);

/**
 * 2. Chargily Webhook Handler
 * Endpoint configured in Chargily Dashboard to receive live payment events.
 * URL: https://us-central1-luckymam-app-dv.cloudfunctions.net/chargilyWebhook
 */
export const chargilyWebhook = onRequest(
  {
    region: "us-central1",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const signature = req.headers["signature"];

      if (!signature) {
        console.warn("[chargilyWebhook] Missing signature header");
        res.status(400).send("Signature header missing");
        return;
      }

      // Verify HMAC-SHA256 signature using the raw body
      const rawBody = req.rawBody ? req.rawBody.toString("utf8") : JSON.stringify(req.body);
      const expectedSignature = crypto
        .createHmac("sha256", CHARGILY_SECRET_KEY)
        .update(rawBody)
        .digest("hex");

      if (signature !== expectedSignature) {
        console.error("[chargilyWebhook] Invalid signature received.");
        res.status(403).send("Forbidden: Invalid signature");
        return;
      }

      const event = req.body;
      console.log(`[chargilyWebhook] Received event type: ${event.type}`);

      // Handle checkout.paid event
      if (event.type === "checkout.paid") {
        const checkoutData = event.data;
        const checkoutId = checkoutData.id;
        const metadata = checkoutData.metadata || {};
        const { userId, type, planTier, orderId } = metadata;

        console.log(`[chargilyWebhook] Checkout paid: ${checkoutId} for user: ${userId}, type: ${type}`);

        const now = new Date();

        // 1. Update payment transaction record
        await db.collection("payment_transactions").doc(checkoutId).set(
          {
            status: "paid",
            amount: checkoutData.amount,
            fees: checkoutData.fees || 0,
            paidAt: admin.firestore.FieldValue.serverTimestamp(),
            chargilyEventId: event.id,
            rawEvent: checkoutData,
          },
          { merge: true },
        );

        // 2. Handle Subscription Upgrade
        if (type === "subscription" && userId) {
          const tier = planTier || "vip";
          // 1 month or 1 year depending on plan
          const isYearly = tier.includes("year") || tier === "vip";
          const endDate = new Date(now);
          if (isYearly) {
            endDate.setFullYear(endDate.getFullYear() + 1);
          } else {
            endDate.setMonth(endDate.getMonth() + 1);
          }

          await db.collection("users").doc(userId).set(
            {
              subscriptionTier: tier,
              subscriptionUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
              subscriptionEndDate: admin.firestore.Timestamp.fromDate(endDate),
              lastPaymentCheckoutId: checkoutId,
            },
            { merge: true },
          );

          console.log(`[chargilyWebhook] User ${userId} upgraded to ${tier} until ${endDate.toISOString()}`);
        }

        // 3. Handle Marketplace Order Confirmation
        if (type === "order" && orderId) {
          const historyAt = now.toISOString().substring(0, 16).replace("T", " ");

          await db.collection("marketplace_orders").doc(orderId).set(
            {
              "payment.method": "chargily",
              "payment.status": "paid",
              "payment.checkoutId": checkoutId,
              status: "confirmed",
              history: admin.firestore.FieldValue.arrayUnion({
                status: "confirmed",
                at: historyAt,
                by: "Chargily Pay (الذهبية/CIB)",
              }),
            },
            { merge: true },
          );

          console.log(`[chargilyWebhook] Order ${orderId} marked as PAID & CONFIRMED`);
        }
      }

      // Handle checkout.failed event
      if (event.type === "checkout.failed") {
        const checkoutId = event.data?.id;
        if (checkoutId) {
          await db.collection("payment_transactions").doc(checkoutId).set(
            {
              status: "failed",
              failedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
        }
      }

      // Respond with 200 OK as required by Chargily documentation
      res.status(200).json({ received: true });
    } catch (error) {
      console.error("[chargilyWebhook] Error processing webhook:", error);
      res.status(500).send("Internal Server Error");
    }
  },
);
