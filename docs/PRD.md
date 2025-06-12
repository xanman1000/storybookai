***📄 PRODUCT REQUIREMENTS DOCUMENT (PRD) — v0.9
Table of Contents
Vision & North-Star

Goals, KPIs & Success Metrics

User & Market Analysis
3.1 Personas
3.2 Competitive Landscape
3.3 Unique Value Props

Detailed User Journeys & Flowcharts

Functional Requirements
5.1 Generation Engine
5.2 Social Layer
5.3 Navigation & Screen-by-Screen Spec
5.4 Notifications Logic
5.5 Search & Discovery
5.6 Pricing & Paywalls
5.7 Content Safety & Moderation

Non-Functional Requirements
6.1 Performance / SLA
6.2 Security, Privacy & Compliance
6.3 Accessibility (WCAG 2.2 AA)
6.4 Localization & I18N
6.5 Observability & Reporting

Design System
7.1 Color Tokens & Typography
7.2 Component Library
7.3 Motion & Micro-Interactions

Supabase Data Model (ER-D, event schema)

Analytics Schema & Funnel Instrumentation

Roadmap & Release Phases

Open Questions & Assumptions

Glossary

1. Vision & North-Star
"Stories at the speed of imagination."
A pastel-perfect playground where anyone can prompt, publish, and share bite-sized illustrated tales in seconds—powered by GPT-4o multimodal magic and wrapped in a friendly social layer.

2. Goals, KPIs & Success Metrics
Goal	Metric (Target 6 mo post-launch)
Sticky creation habit	GenDAU / DAU ≥ 40 %
Viral discovery loop	Avg shares per story ≥ 2
Healthy creator economy	Revenue / Daily Story Gen ≥ $0.05
Retention	D30 retention ≥ 35 %
Safety & trust	User-reported abuse rate < 0.2 % of stories
Perf & reliability	P95 full gen latency ≤ 12 s (text+images)

3. User & Market Analysis
3.1 Personas (expanded)
Persona	Core Needs	Pain Points	Opportunities
Ava (16-25, TikTok native)	Fast, aesthetic content; flex creativity	Plug-ins are technical; Midjourney costly	Simple slider settings; auto hashtags
Raj (Hobby writer, 25-40)	Tone control; versioning; export	Writer's block; no art skills	Fine-grained tone, revision history
Lin (Passive consumer, FOMO)	Curated feed; save & share	Noise; low effort scroll fatigue	Trending + personalized recsys
Sophia (Parent, bedtime stories)	Kid-safe content; read-aloud	NSFW risk; lengthy apps	Child mode; narration toggle
Blitz (Influencer, growth hacker)	Viral hooks; analytics	Platform algorithm opacity	Insights dashboard; follower alerts

3.2 Competitive Landscape
Fable AI, Canva Stories, StoryBird—none combine real-time gen with social graph & safety rails.

Opportunity: first-mover in "micro-social-gen" niche for illustrated fiction.

3.3 Unique Value Props
One-tap multimodal creation (text + 1–3 coherent images).

Pastel-polished mobile UX vs. web-first rivals.

Follow/Trending mechanics similar to TikTok but story-centric.

Built-in parental & creator controls (length caps, tone whitelist).

4. User Journeys & Flowcharts (high-level)
Cold-Start (New User)

Install → sign up (email, Apple, Google) → onboarding carousel (15 s).

Auto-follows "Starter Pack" creators → Discover feed pre-populated.

CTA "Generate your first story" → Generate flow.

Creation Loop

Generate Tab → Prompt (optional) → Gear → adjust Length=Medium, Tone=Whimsical, Style=Watercolor → Tap Generate.

While GPT-4o streaming text, first image previews (progress bar) → Output page with "Publish", "Regenerate", "Save Draft".

Publish → choose tags → share to Discover; notifications to followers.

Consumption Loop

Push notification "Ava posted Rainbow Soup" → tap → story viewer (vertical swipe).

Double-tap like, long-press to bookmark, comment bubble → quick reactions.

Scroll bottom "More like this" carousel.

Monetization Loop

After 5 free gens, soft paywall modal.

"Upgrade to Pro" or use Pay-Per-Story credits → Stripe sheet.

Flow diagrams are linked in Figma (see design assets, section 7).

5. Functional Requirements
5.1 Generation Engine
Req-ID	Description	Priority	Acceptance Criteria
GEN-01	Support three length presets (Short ≤ 120 words, Medium ≤ 250, Long ≤ 500).	P0	Word count not exceeded; validated at server.
GEN-02	Tone whitelist array stored in DB: Whimsical, Dramatic, Cozy, Noir, Sci-Fi, Fantasy, Kids.	P0	UI shows only whitelisted tones.
GEN-03	Illustration style options (Watercolor, Cartoon, Pastel-Flat, Line-Art, Clay-3D, Ukiyo-e).	P0	Returned image conforms to style prompt template.
GEN-04	Result consists of 1 cover image + optional 1–2 inline images with alt-text.	P0	JSON schema validated.
GEN-05	Generation queue uses Supabase Edge Function; if GPT/API fails, graceful retry (max 2).	P1	95 % stories succeed in ≤ 2 tries.

5.2 Social Layer
Follow System: followers (id, user_id, follower_id, created_at) table; API triggers to send "followed you" push.

Likes & Comments: separate counts; real-time optimistic updates.

Trending Score: score = w1*likes + w2*comments + w3*shares + w4*recency_decay. Recomputed hourly via scheduled Edge Job.

5.3 Navigation & Screen Spec
Tab	Screen(s)	Key Elements
Generate	PromptInput, GearModal, LiveProgress, Preview	FAB for regenerate, "premium" badge if pro styles
Discover	Feed (infinite), StoryCard, GenreChips, RefreshControl	Tabs: For You, Trending, Following
Search	SearchBar, ResultsGrid, Filters (tone, style)	Recent searches chips
Notifications	ActivityList, FollowReqs, SystemAlerts	Mark-all-read
Profile	Header (avatar, stats, bio), StoryGrid, Settings cog	"My Drafts", "Purchase History" sub-pages

5.4 Notifications Logic
Event	Push?	In-App badge?
New follower	✔	✔
Story liked/commented	✔ (if >5 likes batched)	✔
Trending Top 10	✔	—
System promo (discount)	—	✔

5.5 Search & Discovery
Elastic full-text on title, tags, author (Supabase pgvector + trigram).

Filter Chips: length type, tone, illustration style.

Auto-suggest trending tags after 3 chars.

5.6 Pricing & Paywalls
Tier	Limits	Perks
Free	5 gens/day; basic tones/styles only	Watermark on cover
Pro	Unlimited; all options; watermark removed	$4.99/mo
Credit Pack	10 premium gens	$2.99 one-time

Stripe Webhooks → supabase.functions.handlePayment.

5.7 Content Safety
OpenAI Moderation P0 before publish.

Vision Safe: test Stable Diffusion NSFW classifier on image bytes as second pass.

User Reports: SLA 24 h manual review; flag column status='flagged'.

6. Non-Functional Requirements
Performance

Cold start Edge Function ≤ 400 ms.

P95 image upload < 1 s (≤ 1 MB PNG).

Security

Row-level security in Supabase (user_id → tenant isolation).

JWT expiry 7 d refresh.

Compliance

GDPR (data export + delete endpoints).

COPPA kid-safe toggle (no profile tracking <13 y/o).

Observability

Supabase logs → Logflare → Grafana dashboards.

Alerts if error rate >2 % in 5 min.

7. Design System
Token	Value	Usage
--color-mint	#C9F2E7	Primary CTA
--color-lavender	#E3D8FF	Secondary background
--font-display	"Poppins-SemiBold"	Titles
Corner radius	16 px	Cards, modals
Motion	250 ms ease-out	Screen transitions

Components stored in Storybook + Figma library.

8. Supabase Data Model (excerpt)
```sql
-- USERS
CREATE TABLE public.users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  email text UNIQUE,
  username text UNIQUE,
  avatar_url text,
  bio text,
  created_at timestamptz DEFAULT now()
);

-- STORIES
CREATE TABLE public.stories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  title text,
  body jsonb,                -- {paragraphs:[{text, image_url, alt}]}
  cover_url text,
  tone text,
  illustration_style text,
  length_preset text,
  visibility text DEFAULT 'public',
  like_count int DEFAULT 0,
  comment_count int DEFAULT 0,
  share_count int DEFAULT 0,
  trending_score numeric DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- FOLLOWS
CREATE TABLE public.follows (
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  follower_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, follower_id)
);
```
(Full ER-diagram in appendix.)

9. Analytics & Funnel
Events (Snowplow-style JSON → Supabase "events" table):
app_opened, story_generated, story_published, story_viewed, follow_clicked, upgrade_clicked, checkout_success, report_submitted.

10. Roadmap & Release Phases
Phase	Deliverables	Duration
0 – Foundations	Supabase project, auth, skeleton RN app, Storybook	2 w
1 – Core Creation	Gen flow w/ GPT-4o, storage, drafts	4 w
2 – Social & Discover	Follow, feed algos, search	3 w
3 – Monetization	Stripe integration, paywalls	2 w
4 – Safety & Polish	Moderation, analytics, A11y audit	2 w
5 – Public Beta	TestFlight/Play Store closed beta	2 w
6 – GA Launch	Press kit, referral program	1 w

11. Open Questions & Assumptions
Illustration style cap? (Currently six)

Voice narration roadmap? (Post-MVP)

Age gating vs. COPPA flow specifics.

12. Glossary
GenDAU: Daily Active Users who generated ≥1 story.

Edge Function: Supabase serverless function proxied at the CDN edge.

RLSE: Row-Level Security Enforcement. 