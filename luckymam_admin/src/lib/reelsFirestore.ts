import type { DocumentData, QueryDocumentSnapshot } from "firebase/firestore";
import { type Reel, type ReelTopic, TOPIC_META } from "@/data/reels.mock";

const VALID_TOPICS = Object.keys(TOPIC_META) as ReelTopic[];

export function normalizeReelTopic(value: unknown): ReelTopic {
  if (typeof value === "string" && VALID_TOPICS.includes(value as ReelTopic)) {
    return value as ReelTopic;
  }
  return "vaccins";
}

export function resolvePlayableVideoUrl(assetPath?: string): string | null {
  if (!assetPath?.trim()) return null;
  const path = assetPath.trim();
  if (/^https?:\/\//i.test(path)) return path;
  if (path.startsWith("gs://")) return null;
  // Legacy Flutter asset paths are not playable in the admin web app.
  return null;
}

export function storagePathFromDownloadUrl(assetPath: string): string | null {
  if (!assetPath.includes("firebasestorage.googleapis.com")) return null;
  try {
    const url = new URL(assetPath);
    const encoded = url.pathname.split("/o/")[1];
    if (!encoded) return null;
    return decodeURIComponent(encoded.split("?")[0] ?? encoded);
  } catch {
    return null;
  }
}

function initialsFromName(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "LM";
  return parts
    .map((part) => part[0])
    .join("")
    .substring(0, 2)
    .toUpperCase();
}

export function mapReelFromFirestore(
  doc: QueryDocumentSnapshot<DocumentData>,
): Reel {
  const data = doc.data();
  const topic = normalizeReelTopic(data.category ?? data.topic);
  const authorName =
    (typeof data.author === "string" && data.author) ||
    (typeof data.creator?.name === "string" && data.creator.name) ||
    "Luckymam";
  const handle =
    (typeof data.creator?.handle === "string" && data.creator.handle) ||
    `@${authorName.toLowerCase().replace(/\s+/g, ".")}`;
  const initials =
    (typeof data.creator?.initials === "string" && data.creator.initials) ||
    initialsFromName(authorName);

  const rawLikes = data.likeCount ?? data.likes ?? 0;

  return {
    id: doc.id,
    title: data.title ?? "",
    description: data.description ?? "",
    duration: data.duration ?? "0:30",
    creator: {
      name: authorName,
      handle,
      initials,
    },
    topic,
    views: Number(data.views ?? 0),
    likes: typeof rawLikes === "number" ? rawLikes : Number(rawLikes) || 0,
    comments: Number(data.comments ?? 0),
    saves: Number(data.saves ?? 0),
    publishedAt:
      data.publishedAt ??
      (data.updatedAt?.toDate?.()
        ? data.updatedAt.toDate().toISOString().split("T")[0]
        : new Date().toISOString().split("T")[0]),
    status: data.status ?? "published",
    featured: Boolean(data.featured),
    assetPath: data.assetPath ?? "",
    vaccineTags: Array.isArray(data.vaccineTags)
      ? data.vaccineTags.map(String)
      : [],
  };
}
