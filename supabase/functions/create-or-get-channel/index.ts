import { createClient } from "npm:@supabase/supabase-js@2";
import { StreamChat } from "npm:stream-chat";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;


function generateStreamId(prefix: string, userIds: string[]): string {
  const combined = [...userIds].sort().join("_");
  let hash = 0;
  for (let i = 0; i < combined.length; i++) {
    hash = (hash << 5) - hash + combined.charCodeAt(i);
    hash = hash & hash;
  }
  return `${prefix}_${Math.abs(hash).toString(36)}`;
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Unauthorized" }, 401);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const token = authHeader.replace("Bearer ", "");
    const { data: { user } } = await supabase.auth.getUser(token);
    if (!user) return json({ error: "Unauthorized" }, 401);

    const { otherUserId } = await req.json();
    if (typeof otherUserId !== "string" || !UUID.test(otherUserId)) {
      return json({ error: "otherUserId must be a valid user id" }, 400);
    }

    const { data: match } = await supabase
      .from("matches")
      .select("user1_id")
      .or(
        `and(user1_id.eq.${user.id},user2_id.eq.${otherUserId}),and(user1_id.eq.${otherUserId},user2_id.eq.${user.id})`,
      )
      .eq("is_active", true)
      .maybeSingle();

    if (!match) return json({ error: "Users are not matched" }, 403);

    const { data: otherUser } = await supabase
      .from("users")
      .select("full_name, avatar_url")
      .eq("id", otherUserId)
      .single();

    if (!otherUser) return json({ error: "User not found" }, 404);

    const stream = StreamChat.getInstance(
      Deno.env.get("STREAM_API_KEY")!,
      Deno.env.get("STREAM_API_SECRET")!,
    );

    await stream.upsertUser({
      id: otherUserId,
      name: otherUser.full_name,
      image: otherUser.avatar_url || undefined,
    });

    const channelId = generateStreamId("match", [user.id, otherUserId]);
    const channel = stream.channel("messaging", channelId, {
      members: [user.id, otherUserId],
      created_by_id: user.id,
    });

    try {
      await channel.create();
    } catch (error) {
      if (!(error instanceof Error) || !error.message.includes("already exists")) {
        throw error;
      }
    }

    return json({ channelType: "messaging", channelId });
  } catch (error) {
    console.error("create-or-get-channel failed:", error);
    return json({ error: "Failed to create channel" }, 500);
  }
});