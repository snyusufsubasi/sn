// supabase/functions/send-push/index.ts
//
// Notification tablosuna yeni satır eklenince çağırılır.
// Kullanıcının aktif device_token'larına FCM HTTP v1 API üzerinden push gönderir.
//
// Setup:
// 1. Firebase Console → Project Settings → Service accounts → Generate new private key
//    → indirilen JSON'un içeriğini base64'le ve Supabase secret olarak ekle:
//    supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat firebase-adminsdk.json | base64)"
// 2. supabase functions deploy send-push
// 3. (Opsiyonel ama önerilir) Webhook imza secret'i:
//    supabase secrets set SEND_PUSH_WEBHOOK_SECRET="<uzun-rastgele-secret>"
//
// Çağırma şekli:
//   POST {SUPABASE_URL}/functions/v1/send-push
//   { user_id, title, body, data }
//
// Bu fonksiyon HTTP webhook olarak Supabase Database Webhooks üzerinden
// notifications tablosundaki INSERT olayına bağlanabilir.
// (Database → Webhooks → Create → Table: notifications, Event: INSERT)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface WebhookPayload {
  type: "INSERT";
  table: "notifications";
  record: {
    id: string;
    user_id: string;
    type: string;
    title: string;
    body: string;
    data: Record<string, unknown> | null;
  };
  schema: "public";
}

// Google FCM access token (OAuth2 ile alınır, 1 saat geçerli)
let cachedToken: { token: string; expiresAt: number } | null = null;

async function getAccessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.token;
  }

  const serviceAccountB64 = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!serviceAccountB64) {
    throw new Error("FCM_SERVICE_ACCOUNT_JSON env yok");
  }
  const serviceAccount = JSON.parse(atob(serviceAccountB64));

  const now = Math.floor(Date.now() / 1000);
  const jwt = await createJWT({
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }, serviceAccount.private_key);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    throw new Error(`OAuth token alınamadı: ${await res.text()}`);
  }
  const { access_token, expires_in } = await res.json();
  cachedToken = {
    token: access_token,
    expiresAt: Date.now() + expires_in * 1000,
  };
  return access_token;
}

async function createJWT(
  payload: Record<string, unknown>,
  pemKey: string,
): Promise<string> {
  // PEM → PKCS8 dönüşümü
  const pemBody = pemKey
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binaryKey = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const header = { alg: "RS256", typ: "JWT" };
  const enc = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");
  const toSign = `${enc(header)}.${enc(payload)}`;
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(toSign),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
  return `${toSign}.${sigB64}`;
}

async function sendToToken(
  projectId: string,
  accessToken: string,
  token: string,
  notification: { title: string; body: string },
  data: Record<string, string>,
): Promise<{ ok: boolean; status: number; body: string }> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification,
          data,
          android: {
            priority: "HIGH",
            notification: { sound: "default", channel_id: "araciyok_default" },
          },
          apns: {
            payload: { aps: { sound: "default", badge: 1 } },
          },
        },
      }),
    },
  );
  return { ok: res.ok, status: res.status, body: await res.text() };
}

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response("method not allowed", { status: 405 });
    }

    const expectedSecret = Deno.env.get("SEND_PUSH_WEBHOOK_SECRET");
    if (expectedSecret) {
      const incomingSecret = req.headers.get("x-webhook-secret");
      if (incomingSecret != expectedSecret) {
        return new Response("unauthorized", { status: 401 });
      }
    }

    const payload = (await req.json()) as WebhookPayload;

    if (payload.type !== "INSERT" || payload.table !== "notifications") {
      return new Response("ignored", { status: 200 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Kullanıcının aktif token'larını çek
    const { data: tokens, error } = await supabase
      .from("device_tokens")
      .select("token, platform")
      .eq("user_id", payload.record.user_id)
      .eq("is_active", true);

    if (error) throw error;
    if (!tokens || tokens.length === 0) {
      return new Response("no tokens", { status: 200 });
    }

    const serviceAccountB64 = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON")!;
    const serviceAccount = JSON.parse(atob(serviceAccountB64));
    const projectId = serviceAccount.project_id;
    const accessToken = await getAccessToken();

    const dataPayload: Record<string, string> = {
      notification_id: payload.record.id,
      type: payload.record.type,
    };
    // record.data içindeki tüm değerleri string'e çevirip ekle
    if (payload.record.data) {
      for (const [k, v] of Object.entries(payload.record.data)) {
        if (v !== null && v !== undefined) dataPayload[k] = String(v);
      }
    }

    const results = await Promise.allSettled(
      tokens.map((t) =>
        sendToToken(
          projectId,
          accessToken,
          t.token,
          { title: payload.record.title, body: payload.record.body },
          dataPayload,
        )
      ),
    );

    // Başarısız (özellikle 404 = invalidated) token'ları deaktive et
    for (let i = 0; i < results.length; i++) {
      const r = results[i];
      if (r.status === "fulfilled" && !r.value.ok) {
        const isInvalid =
          r.value.status === 404 ||
          r.value.body.includes("UNREGISTERED") ||
          r.value.body.includes("INVALID_ARGUMENT");
        if (isInvalid) {
          await supabase
            .from("device_tokens")
            .update({ is_active: false })
            .eq("token", tokens[i].token);
        }
      }
    }

    return new Response(
      JSON.stringify({
        sent: results.filter((r) => r.status === "fulfilled" && r.value.ok)
          .length,
        total: results.length,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error("send-push error", e);
    return new Response(`error: ${e}`, { status: 500 });
  }
});
