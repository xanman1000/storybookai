***🛠️ TECHNICAL IMPLEMENTATION PLAN — v0.9
Table of Contents
High-Level Architecture

Tech Stack & Key Libraries

Project Structure & Conventions

Supabase Schema (DDL) & Edge Functions

Client-Server Contracts (REST/RPC examples)

AI Service Integration (GPT-4o + Image Gen)

State Management & Caching Strategy

Auth & Security Design

CI/CD & Environments

Testing Matrix

Observability & Incident Response

Dev Roadmap & Sprint Backlog

Cost Estimates & Scalability

Risks & Mitigations

References & Tooling Links

1. High-Level Architecture
```mermaid
graph TD
  subgraph Mobile
    RNApp[React Native App]
  end
  RNApp -->|HTTPS| EdgeFns(Supabase Edge Functions)
  RNApp --> SupabaseRT[Realtime Channels]
  EdgeFns --> PG[(Postgres DB)]
  EdgeFns --> Storage[Supabase Storage (Images)]
  EdgeFns --> Stripe[Stripe Webhooks]
  EdgeFns --> OpenAI[GPT-4o & Image APIs]
  OpenAI -->|mod| Safety[OpenAI Moderation]
```
Data plane: Supabase Postgres + Storage with row-level security.

Control plane: Edge Functions (Node 18).

Realtime for likes/comments via supabase-js subscription.

2. Tech Stack & Key Libraries
| Layer | Tech | Notes |
|-------|------|-------|
| Mobile | React Native 0.74 (Expo SDK > 51) | EAS build; Hermes engine |
| State | Zustand + react-query | Lightweight, SSR not needed |
| UI | Tamago UI Kit (custom pastel) + react-navigation v7 | BottomTabNavigator |
| Auth | @supabase/auth-react-native | OAuth (Apple, Google) |
| Payments | Stripe React Native | In-app purchase fallback (Expo IAP) |
| Image upload | expo-image-picker + supabase-js upload | Resized client-side → PNG |
| Type safety | TypeScript 5.x | API types generated via openapi-typescript |
| Linting | ESLint, Prettier, Husky pre-commit | Conventional commits |
| Tests | Jest (unit), React Native Testing Library (component), Detox (E2E) |

3. Project Structure
```bash
/app
  /components
  /screens
  /navigation
  /store              (Zustand)
  /services
    supabase.ts
    openai.ts
    stripe.ts
  /hooks
  /utils
  /assets
  App.tsx
/functions           (Supabase EdgeFns)
  generateStory.ts
  trendingJob.ts
  handlePayment.ts
/database            (schema.sql, seed.sql)
```
4. Supabase Schema & Edge Functions
4.1 DDL Snippet (additional tables)
```sql
CREATE TABLE public.comments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  story_id uuid REFERENCES public.stories(id) ON DELETE CASCADE,
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  body text,
  created_at timestamptz DEFAULT now()
);

-- RLS for comments
CREATE POLICY "users can insert own comments"
  ON public.comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

-- Example Edge Function: generateStory.ts
```ts
export const onRequest = async (req) => {
  const { prompt, length, tone, style } = await req.json();
  // Validate & sanitize
  const safe = await openai.moderate(prompt);
  if (!safe) return new Response("Unsafe content", { status: 400 });
  // Build system prompt
  const sysPrompt = `Write a ${tone} short story ≤${length} words...`;
  const story = await openai.chatCompletion(sysPrompt);
  const cover = await openai.imageGenerate(`${style} illustration of ...`);
  // Insert story
  const { data } = await supabase.from('stories').insert({ ... });
  return Response.json(data);
};
```
4.2 Scheduled Job
`trendingJob.ts`: runs hourly → recompute trending_score.

5. Client-Server Contracts
| Endpoint (EdgeFn) | Method | Body | Response |
|-------------------|--------|------|----------|
| /generateStory | POST | {prompt?, lengthPreset, tone, style} | {storyId} |
| /toggleLike | POST | {storyId} | {likeCount} |
| /followUser | POST | {targetUserId} | {isFollowing} |

All responses follow { data, error } envelope.

6. AI Service Integration
GPT-4o (model =gpt-4o-mini for cost, fallback = gpt-4o)

Temperature 0.8; max_tokens dynamic.

Prompt template stored in Supabase prompts table for easy A/B.

Images

image_gen.text2im API; size 1024²; n=1.

Style injection: "in the style of ${style}, pastel color palette".

Moderation

openai.moderations.create({ input }) for text.

After image generation, run NSFW classifier.

7. State & Caching
react-query caches stories by ['story', id] TTL 5 min.

Infinite scroll uses useInfiniteQuery.

Local draft save via AsyncStorage (drafts/ key namespace).

8. Auth & Security
JWT stored in secure storage (expo-secure-store); refresh silently.

RLS policies ensure users can only mutate own rows.

Content delivery via signed URLs (public stories get permanent, drafts get 24 h signed links).

9. CI/CD & Environments
| Stage | Tooling |
|-------|---------|
| Lint/Test | GitHub Actions → pnpm install, ESLint, Jest |
| Build | EAS Build (dev, staging, prod profiles) |
| Deploy EdgeFns | GH Action → supabase functions deploy |
| Release | Staging (TestFlight/Internal) → manual QA → Production rollout 20 % phased |

Secrets stored in GH OIDC → Supabase & OpenAI keys.

10. Testing Matrix
| Layer | Technique | Coverage Target |
|-------|-----------|-----------------|
| Unit | Jest | 80 % lines |
| Component | RN Testing Library | All interactive components |
| API | Insomnia tests + contract unit tests | 100 % critical routes |
| E2E | Detox on iOS + Android | Core create → publish → like |
| Load | k6 on /generateStory (500 RPS burst) | Latency < 1.5× baseline |

11. Observability & Incident Response
Logs: Supabase → Logflare.

Metrics: Prometheus exporter for EdgeFn durations; Grafana dashboards.

Alerts: PagerDuty if P95 > 15 s or 5xx > 1 %.

Playbook: On-call rotation, runbook stored in Notion.

12. Dev Roadmap & Sprint Backlog
| Sprint | Duration | Goals |
|--------|----------|-------|
| 0 | 1 w | Repo setup, CI, schema scaffold, color tokens. |
| 1 | 2 w | Auth flows, bottom nav, Generate MVP (text only), RLS. |
| 2 | 2 w | Image generation integration, Storage uploads, draft save. |
| 3 | 2 w | Follow system, Feed (Following & For You v0), like/comment. |
| 4 | 1 w | Search, PG full-text, tags. |
| 5 | 1 w | Paywalls, Stripe, credit packs, soft launch. |
| 6 | 2 w | Moderation v2, analytics events, E2E tests, A11y audit. |

13. Cost Estimates (Monthly)
| Item | Units | Cost |
|------|-------|------|
| Supabase Pro 50 K MAU | 1 | $25 |
| GPT-4o (250 K tokens) | ~50 K stories | $50 |
| Image Gen (50 K × $0.01) | 50 K | $500 |
| Stripe fees | 3 % rev share | — |
| EAS Build/OTA | 1 | $29 |

Breakeven @ ~200 Pro subs.

14. Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| API cost overrun | Medium | High | Hard caps per tier; alerting |
| NSFW bypass | Medium | High | Dual-layer moderation, user reports |
| App Store rejection (AI content) | Low | High | Follow Apple 5.2.3; age rating 12+ |
| OpenAI rate limit | Low | Medium | Queue + exponential backoff |

15. References & Tooling Links
Figma design file: n/a (code-driven UI)

Storybook link: n/a (to be added later)

Supabase docs: supabase.com/docs

GPT-4o API: platform.openai.com/docs/models/gpt-4o 