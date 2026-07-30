# Sniff — Product Brief & Handoff Document

**One tiny enrichment activity a day, for your dog or cat.**

*Working name. Status: pre-build concept. Last updated: July 2026.*

---

## 0. How to read this document

This is a handoff brief, not a spec sheet. It contains the research that led to the idea, the competitive reasoning, the product design, the technical shape, the cost model, and the go-to-market plan. Sections 1–4 are the *why*. Sections 5–9 are the *what*. Sections 10–13 are the *how*. Section 14 lists what we still don't know.

An interactive prototype accompanies this document (`sniff-prototype.html`). Open it in a browser and click through — it's the fastest way to understand the product.

Nothing here is built yet. Assumptions that need validating are flagged inline with **[VERIFY]**.

---

## 1. The thesis

Two bodies of work sit behind this product.

**Kaizen** — the Japanese philosophy of continuous small improvement — holds that tiny, sustained changes compound into large outcomes, and that the size of the step matters less than the fact that you keep taking it.

**BJ Fogg's Tiny Habits** research adds the mechanism: make the behavior so small it's almost impossible to fail, anchor it to something you already do, and celebrate immediately. Fogg's core insight is that motivation is unreliable, so you engineer around it by shrinking the behavior until motivation isn't required.

Almost every consumer habit product claims this lineage and then violates it. They ask for 20 minutes, they use streaks that punish a single missed day, and they escalate difficulty faster than a beginner can absorb.

We found the clearest evidence of this in an adjacent category: **Couch to 5K has a documented dropout rate around 64.5%**, which researchers attribute to injury and aggressive progression — particularly the difficulty jump at week five. A program specifically designed for beginners loses roughly two thirds of them because it isn't actually gentle.

**Sniff applies the kaizen principle honestly.** One activity. Three to ten minutes. Uses things already in the house. No streaks. If you miss three days, nothing breaks.

---

## 2. Why pet enrichment specifically

We evaluated thirteen candidate problem spaces against three criteria: is the pain real and recurring, is the natural solution genuinely tiny, and is the space underserved by software. Pet enrichment scored well on all three.

### The pain is real and recurring

Pet enrichment has moved from niche trainer vocabulary to mainstream veterinary advice over the last five years. The consensus across the ASPCA, Purina, Preventive Vet, and shelter organizations is consistent: dogs and cats were bred for jobs they no longer have, and without outlets for foraging, hunting, chewing, and scent work, they develop behavioral problems — destructive chewing, counter surfing, excessive barking, litter box avoidance, separation distress.

Preventive Vet frames it memorably: dogs were bred to work, and we have effectively left them unemployed.

Owners feel this as guilt. They know their pet needs more than a walk and a bowl. They read an article, buy a snuffle mat, use it four times, and it ends up in a closet.

### The solution is naturally tiny

This is the strongest fit signal. Enrichment genuinely works in small doses — and one of the most common misconceptions in the space, as canine enrichment educators repeatedly point out, is that owners expect an activity to occupy the dog for an hour. It doesn't need to. A three-minute foraging session does real work. Trainers commonly note that a short period of sniffing tires a dog more than a substantially longer walk. **[VERIFY]** — this ratio is widely repeated in training content but we should source a defensible version before using it in marketing.

The kaizen framing isn't a marketing overlay here. It's how the domain actually works.

### The space is underserved by software

This is where it gets interesting, and where we did the most work.

---

## 3. Competitive landscape

We went looking for a dedicated pet enrichment app. There isn't a dominant one.

### What exists in software

**Pet care trackers.** DogCat App, Pet Care Tracker, and similar products handle vaccinations, medication, vet appointments, growth milestones, feeding logs, and potty tracking. Some include photo galleries. None of them are about enrichment — they're medical and administrative record-keeping.

**Brand apps.** myPurina has been downloaded by over two million pet parents and publishes enrichment *content*, but the app's core job is loyalty, product, and general pet care. Enrichment is an article category, not a daily product loop.

**Walking and activity trackers.** Various GPS/step products. Physical exercise, not mental stimulation.

**Training apps.** Some exist for obedience and trick training. Adjacent but distinct — training is skill acquisition with a goal; enrichment is need-satisfaction with no endpoint.

### What exists outside software

This is the demand proof.

**Physical products.** Woofsie sells a 52-card enrichment activity deck. Soda Pup, Lickimat, and others sell enrichment tools (lick mats, snuffle mats, puzzle feeders) as a growing product category. PetSuites and other boarding chains sell enrichment as a paid add-on service and report it as their most positively reviewed offering.

**Content.** ASPCA, Purina, Preventive Vet, Jacksonville Humane Society, Animal Friends, and dozens of independent creators publish extensive enrichment guides. Wear Wag Repeat, a canine-enrichment-focused blog, sells paid digital products around it. There is a substantial creator economy on TikTok and YouTube around DIY enrichment.

**Institutional endorsement.** Shelters and humane societies actively promote enrichment as a behavioral intervention and an adoption-retention tool. This matters enormously for distribution — see section 12.

### The gap, stated plainly

There is a large, growing, institutionally endorsed body of enrichment knowledge, a healthy market for enrichment *products*, and an active creator economy — and no app that turns any of it into a daily habit.

The gap is not "nobody knows about enrichment." It's "nobody has built the thing that makes you actually do it today."

### Honest counter-arguments

We should be clear-eyed about the risks, because this is a handoff document and not a pitch deck.

**The content is free and abundant.** Everything Sniff would surface exists somewhere online for free. Our value is curation, sequencing, personalization, and the daily prompt — not proprietary knowledge. That's a real but defensible position (it's the same position Headspace occupies relative to free meditation content).

**Pet apps have historically monetized poorly.** Many are free, ad-supported, or brand-subsidized. We are betting that a focused, well-designed product can command a modest subscription, but the price ceiling is lower than in wellness or productivity.

**A big pet brand could enter.** Purina, Chewy, or a pet insurance company could build this and give it away. Our defense is speed, quality, and the fact that big-brand apps tend to be product-catalog-shaped rather than habit-shaped.

**Retention is unproven.** The daily-prompt model could suffer the same fate as the snuffle mat in the closet. Section 13 covers how we test this before building.

---

## 4. Target market

### Primary persona: the guilty enthusiast

Owns one or two pets. Loves them intensely. Has read enough to know that walks and food aren't enough. Has bought at least one enrichment product. Follows at least one pet account on social media.

The gap between how much they care and how much they actually do is the emotional engine of this product. They don't need convincing that enrichment matters. They need the decision removed.

Skews 25–45, skews female (consistent with pet content consumption patterns generally), urban and suburban, likely to describe the pet as family.

### Secondary persona: the problem-solver

Their dog is destroying furniture. Their cat is yowling at 4am. Their new rescue is anxious. They've googled the behavior and landed on enrichment as an intervention.

Higher urgency, higher willingness to pay, lower long-term retention once the acute problem resolves. Valuable for acquisition; less valuable for LTV. Worth serving with a dedicated onboarding path.

### Tertiary persona: the new adopter

Just brought home a rescue or puppy or kitten. In a high-motivation, high-uncertainty window. Extremely receptive to structure. This is also the persona most reachable through shelter partnerships.

### The cat opportunity

Cat enrichment is meaningfully underserved relative to dog enrichment across every channel we examined — content, products, and community. Cat owners get a fraction of the material dog owners do, and cat enrichment is genuinely different (scent-driven, hunting-sequence-driven, environment-driven rather than handler-driven).

**Recommendation: build dog and cat from day one, but market cat harder.** Dog is the bigger market; cat is the emptier one. A cat-first marketing wedge into a product that also serves dogs is likely the most efficient path in.

### Sizing

The US pet care market is very large — commonly cited in the range of $150B annually **[VERIFY: source this properly before it goes in any deck]**. That number is not directly useful, since it's dominated by food and veterinary care.

More useful framing: myPurina's two-million-download figure gives a sense of how many owners will install a pet app. The subset who will pay a monthly subscription for behavior and enrichment is much smaller. We should model conservatively — assume this is a business that could reach tens of thousands of paying subscribers, not millions, unless something unexpected happens.

---

## 5. Product principles

These are the constraints. Everything in section 6 follows from them.

**1. One thing a day.** Not a list. Not a plan. One activity, chosen for you. The user's only decision is whether to do it.

**2. No streaks, ever.** Missing a day does not break anything. Progress is cumulative and additive — "42 activities this year" — never consecutive. This is the single most important differentiator and it should be visible in the UI, not just true in the database.

**3. Use what's already in the house.** The default activity should never require a purchase. Towels, boxes, cups, muffin tins, toilet roll tubes, kibble the pet already eats. Purchasable tools (snuffle mats, lick mats) can appear as optional upgrades but never as prerequisites.

**4. Enrichment is bonding, not babysitting.** Set the expectation up front that a three-minute activity is a success, and that the point is shared attention rather than occupying the pet. This directly counters the most common owner misconception in the space and it's a genuine differentiator in tone.

**5. The pet is the hero, not the user's discipline.** The emotional payoff is the pet's visible enjoyment and the accumulating photo record — not the user's consistency score.

**6. Rest is part of the program.** After high-stimulation activities, suggest calm ones. The product should model good enrichment practice, which includes downtime.

---

## 6. Product requirements

### 6.1 Core loop

```
Morning notification
        ↓
Open → see today's one activity
        ↓
Tap through → steps + why it works
        ↓
Do it (2–10 min)
        ↓
Mark done → optional photo → one-tap reaction
        ↓
Reaction feeds tomorrow's selection
```

Total in-app time on a normal day: under 90 seconds. The activity happens away from the phone. This is deliberate — the app should get out of the way.

### 6.2 Onboarding

Target completion: under three minutes. Every question must earn its place by changing the recommendations.

| Step | Question | Why it's asked |
|---|---|---|
| 1 | Dog or cat | Forks the entire content library |
| 2 | Name, age band, size band | Personalization; filters age/size-inappropriate activities |
| 3 | Energy level (low / medium / high) | Sets baseline activity intensity |
| 4 | Any limitations? (mobility, resource guarding, food allergies, senior, anxious) | Excludes unsuitable activities — safety-critical |
| 5 | What do you have? (checklist: treats, kibble, peanut butter, towels, cardboard, muffin tin, lick mat, snuffle mat, puzzle toy, wand toy, etc.) | Constrains recommendations to what's achievable today |
| 6 | When should we nudge you? | Sets the anchor time |

Multi-pet households create separate profiles. The daily card shows one pet at a time with a switcher; **do not** show two activities at once, that violates principle 1.

**Optional branch:** an entry path for the problem-solver persona — "Is there a behavior you're trying to work on?" (destructive chewing, barking, anxiety, night activity, litter box issues, resource guarding). If selected, bias early recommendations toward relevant categories and surface a short explainer connecting the behavior to the enrichment need. Note clearly that this is not veterinary or behavioral diagnosis and recommend professional consultation for serious issues.

### 6.3 Today screen

The heart of the product. Contains:

- Pet identity (name, avatar) — small, top of screen
- One activity card: name, duration, category tag, materials needed, a one-line description, and a visual
- Primary action: **Start**
- Secondary action: **Not today** — swaps for an alternative, logs the skip (skips are signal, not failure)
- No streak counter, no completion percentage, no red anything

The "not today" swap should be generous — let people cycle three or four times without friction. A user who swaps to find something they'll actually do is a success, not a defection.

### 6.4 Activity detail

- Title, category, duration, materials
- **Why this works** — a short note on the instinct being satisfied. This is the most under-served content in the space and a real differentiator. Owners who understand *why* keep doing it.
- Numbered steps, 3–6 of them, written for someone holding a phone in one hand
- Visual: illustration or short looping clip
- Safety note where relevant (supervision required, choking risk, not for resource guarders)
- Primary action: **Mark done**

### 6.5 Completion

- Confirmation that doesn't over-celebrate. Warm, brief, no confetti.
- Optional photo — one tap to camera. This drives the memory grid and is the strongest retention mechanic in the product.
- One-tap reaction: **Loved it / Fine / Too hard / Not interested**. Four options, no free text required. This is the entire feedback loop for the recommendation engine.
- Optional free-text note for people who want to journal it.

### 6.6 Memory grid

A scrapbook, not a dashboard. Chronological grid of completed sessions with photos where they exist and activity marks where they don't. Cumulative counts only — "37 activities, 24 photos" — never consecutive.

Include a "most loved" summary derived from reactions. Include a monthly or yearly shareable summary; this is organic acquisition.

### 6.7 Library

Browsable and filterable by time available, category, and materials on hand. Saved favorites surface first. This exists for the days when the daily card doesn't fit the situation — raining, sick pet, guests over, five minutes before work.

Filters that matter most: **time** and **what I have**. Category filtering is secondary.

### 6.8 Notifications

One per day, at the user's chosen anchor time, phrased as an invitation rather than an obligation. Never guilt-based. Never "you've missed 3 days."

Copy direction: *"Today for Luna: towel burrito. 3 minutes, needs a towel."* — specific and low-friction, so the decision to do it can happen from the lock screen.

If a user has been inactive for two weeks, one gentle re-engagement message, then stop. Do not escalate.

### 6.9 Explicitly out of scope for v1

- Social features, feeds, following other users
- Community-submitted activities
- Video-heavy content (see section 8)
- Hardware integration
- Vet or trainer marketplace
- Multi-species beyond dog and cat
- Web app
- Any form of streak, chain, or consecutive-day mechanic

---

## 7. Recommendation engine

Rules-based, not ML. This is genuinely sufficient for v1 and much easier to debug, explain, and tune.

**Hard filters** (never violated):
- Species match
- Age and size appropriateness
- Declared limitations (mobility, allergies, resource guarding)
- Materials available

**Rotation rules:**
- Don't repeat an activity within 10 days unless it's a saved favorite
- Rotate across categories — don't serve three foraging activities in a row
- After a high-arousal activity, bias toward calm/passive the next day
- Respect declared time availability patterns (if a user consistently completes only 3-minute activities, stop offering 15-minute ones)

**Difficulty progression:**
- Start at the easiest tier regardless of stated energy level. Earning trust matters more than matching capability.
- Escalate slowly — advance a tier only after several successful completions in a category
- Drop back a tier after a "too hard" reaction

**Reaction weighting:**
- *Loved it* → boost that category, unlock the next tier within it
- *Fine* → neutral
- *Too hard* → drop tier, suppress similar for two weeks
- *Not interested* → suppress that activity permanently, down-weight its category
- *Skipped* → mild down-weight, no suppression

**Cold start:** first seven days are a fixed, hand-designed sequence covering four categories at the easiest tier. This is a curated experience, not an algorithmic one. It should be the best week of content we have.

---

## 8. Content strategy

**Content is the product.** The software is a delivery mechanism. Budget and staff accordingly.

### Taxonomy

Six categories, following the consensus framing used across veterinary and boarding sources:

| Category | What it satisfies | Examples |
|---|---|---|
| Foraging / food | Hunting and scavenging instinct | Scatter feeding, snuffle mat, towel burrito, muffin tin puzzle |
| Sensory | Smell, sight, sound, texture | Sniff walks, scent gardens, bubbles, new textures |
| Cognitive | Problem-solving | Three-cup game, hide and seek, name-that-toy, trick learning |
| Physical | Fitness and coordination | Flirt pole, tug, obstacle courses, wand play |
| Social | Interaction with people or animals | Structured play, cooperative games, focused attention time |
| Passive / calming | Rest and decompression | Lick mats, long chews, window perches, calming music |

### Activity schema

Every activity record needs:

```
id, species, title, category, tier (1–5)
duration_minutes, materials[] (with required/optional flags)
description (one line, ~20 words)
why_it_works (2 sentences, names the instinct)
steps[] (3–6, imperative, one action each)
safety_notes[] (nullable)
age_range, size_range, energy_match
exclusions[] (resource_guarding, mobility_limited, etc.)
visual_asset_id
```

### Volume targets

- **Launch:** 200 activities (roughly 120 dog, 80 cat). Enough for six months without meaningful repetition.
- **Month 6:** 350
- **Year 1:** 500+

The cat library should be built by a feline behavior specialist, not translated from the dog library. Cat enrichment has a different structure — it follows the hunt sequence (stalk, chase, pounce, kill, eat, groom, sleep) and leans heavily on environment and scent. Treating it as "dog activities but smaller" is the most likely way to get this wrong.

### Who writes it

Hire two content authorities:
- A certified canine enrichment specialist or credentialed trainer (CPDT-KA, CBCC-KA, or equivalent) for the dog library
- A certified feline behavior consultant for the cat library

Budget **$10–20K** for the initial 200-activity library, then **$1–3K/month** for ongoing production. Every activity should be reviewed for safety before publication. This is not optional — a poorly specified activity can injure an animal.

### Visual content

The cost trap. Three options, in order of preference for v1:

1. **Illustration.** A consistent illustrated style for every activity. Cheapest to produce at volume, no streaming cost, becomes brand equity, and looks intentional rather than stock. **Recommended for v1.**
2. **Short looping clips** (5–10 seconds, silent, muted autoplay). Add selectively for activities where the mechanics are hard to describe. Small files, manageable cost.
3. **Full video demonstrations.** Expensive to produce and to stream. Defer.

The user's own photos are the emotional visual content. Our job is to make the instructional visuals clear and get out of the way.

---

## 9. Design direction

### Voice

Warm, plain, and specific. Never cutesy, never clinical. The reader is an intelligent adult who loves an animal.

- Say "3 minutes, needs a towel" not "quick and easy fun for your furry friend!"
- Say "she'll use her nose to unroll it" not "watch the magic happen"
- No baby talk, no exclamation-mark inflation, no "pawsome"
- Errors and empty states explain what to do, not apologize

### Tone rules for the anti-streak position

Say it out loud in the interface. On the memory screen: *"No streaks. Off days are just off days."* Users who have been burned by Duolingo-style mechanics need to be told explicitly that this product is different, because they will assume otherwise.

### Visual identity

The prototype (`sniff-prototype.html`) implements a direction: sage-toned paper, deep forest ink, a fresh grass-green accent, and a warm ochre for the "why this works" notes. Display typography is warm and slightly wonky (Fraunces); UI type is clean and friendly.

The intent is domestic and tactile — towels, cardboard, grass — rather than clinical wellness-app minimalism or bright cartoon pet-brand energy.

Treat this as a starting point for a designer, not a final identity.

---

## 10. Technical architecture

### Stack

Deliberately boring. Nothing here is hard.

| Layer | Choice | Notes |
|---|---|---|
| Mobile | React Native or Flutter | Cross-platform; this is not a platform-differentiated product |
| Backend | Node or Python, small REST API | Low complexity |
| Database | Postgres (Supabase or Neon) | Relational fits the content model well |
| Auth | Apple / Google sign-in | Minimal friction |
| Object storage | S3, R2, or Supabase Storage | User photos |
| Push | Firebase Cloud Messaging or OneSignal | Free tier covers early scale |
| Analytics | PostHog or Amplitude | Retention analysis is critical here |
| Payments | RevenueCat | Handles both stores' subscription complexity |

### Data model sketch

```
users        → id, auth, timezone, notification_time, subscription_status
pets         → id, user_id, species, name, age_band, size_band,
                energy_level, limitations[], materials[]
activities    → (content library, see section 8 schema)
sessions      → id, pet_id, activity_id, completed_at,
                reaction, photo_url, note
recommendations → id, pet_id, activity_id, served_at, outcome
```

### What genuinely doesn't need building

- **No ML.** The rules engine in section 7 is enough for a long time.
- **No LLM at launch.** A v2 "ask about a behavior" feature could use one, at trivial cost given the call volume. Not needed for the core loop.
- **No real-time anything.**
- **No offline-first complexity** beyond caching today's activity so it's readable without signal.

### The actual engineering risks

1. **Photo upload reliability.** It's the retention mechanic. It must never fail silently.
2. **Notification delivery.** A daily-prompt product where the prompt doesn't arrive is dead. Test aggressively across OS versions and battery-optimization settings.
3. **Content pipeline.** Non-engineers need to author, review, and publish activities without a developer. Build a simple CMS (or use an off-the-shelf headless CMS) in week one, not month six.

---

## 11. Operating costs and unit economics

### Recurring infrastructure

| Line item | 1,000 paid users | 10,000 paid users |
|---|---|---|
| Backend hosting + database | $25–75/mo | $150–400/mo |
| Photo storage + egress | $10–30/mo | $100–300/mo |
| Push notifications | $0 (free tier) | $0–100/mo |
| Analytics | $0–50/mo | $100–300/mo |
| **Infrastructure subtotal** | **$35–155/mo** | **$350–1,100/mo** |

Assumes text and image content, illustration rather than video. Adding video content could add $50–200/mo at 1,000 users and scale roughly linearly with engagement.

### Content (the real cost)

| Line item | Cost |
|---|---|
| Initial 200-activity library (2 specialists) | $10–20K one-time |
| Initial illustration set | $5–15K one-time |
| Ongoing content production | $1–3K/mo |

### Unit economics

At a **$5.99/month or $39.99/year** price point:

- App store takes 15% (small business program) to 30%
- Net revenue per annual subscriber: roughly $28–34
- Infrastructure cost per user per year: well under $2
- Content cost amortized across the base is the dominant variable

**Gross margin lands around 60–70%** — good, but tighter than a pure-software product because content production never stops. The break-even point is heavily dependent on how fast the content library needs to grow, which in turn depends on retention. A user who churns at month four never exhausts the launch library; a user who stays two years does.

**Implication for planning:** don't over-invest in library size before you know retention. Launch with 200, watch how fast people consume it, then scale content spend to match.

---

## 12. Go-to-market

### Positioning

> *For people who know their pet needs more than a walk, and never know what to actually do.*

Position against **effort**, not against competitors. There's no incumbent to attack. The enemy is the snuffle mat in the closet.

### Channel 1: Shelters and rescues (highest conviction)

Shelters actively promote enrichment, publish enrichment content, and have a direct interest in adoption retention — enrichment reduces the behavioral problems that cause returns.

Offer free lifetime or one-year access codes for every adopter, distributed in the adoption packet. This gives us:
- Trusted third-party endorsement at the highest-motivation moment in a pet owner's life
- Access to the new-adopter persona at zero CAC
- A genuine social good story that supports PR and content

Start with 5–10 shelters, measure activation, then scale. This is the single most important channel to test.

### Channel 2: Vets and behaviorists

Vets recommend enrichment for behavioral issues but have nothing concrete to hand over. A prescription-pad-style card or a referral code fits an existing workflow. Slower to build than shelters but higher trust.

### Channel 3: Organic social

Enrichment content performs well on TikTok, Instagram Reels, and YouTube Shorts — the format (short, visual, immediately actionable, cute animal) is native to the platform.

Post the activities themselves, not the app. Build an audience around free enrichment content and let the app be the obvious next step. This is the same playbook Bend used effectively in the stretching category, where it accumulated tens of millions of views.

**The cat wedge belongs here.** Cat enrichment content is underserved and cat content performs well. Lead with cats.

### Channel 4: Communities

r/dogs, r/dogtraining, r/puppy101, r/cats, r/CatAdvice, r/reactivedogs, breed-specific groups and forums. Participate genuinely; these communities punish marketing. Useful primarily for early user research and beta recruitment rather than scaled acquisition.

### Channel 5: Creator partnerships

The enrichment creator economy already exists (Wear Wag Repeat and similar). Affiliate arrangements with established enrichment educators put the product in front of a pre-qualified audience.

### Pricing

- **Free tier:** one activity a day, one pet, basic library access. Genuinely useful — a free user who does enrichment daily is a marketing asset.
- **Paid ($5.99/mo or $39.99/yr):** multiple pets, full library with filters, photo memory grid, unlimited saves, monthly recaps.

Put the photo memory grid behind the paywall. It's the feature people become attached to, and it gets more valuable the longer they use it.

### Launch sequence

| Phase | Duration | Goal |
|---|---|---|
| Validation | 4–6 weeks | Pre-build. See section 13. |
| Content build + MVP | 10–14 weeks | 200 activities, core loop, one platform |
| Closed beta | 4 weeks | 100–200 users from shelters and communities |
| Shelter pilot | 8 weeks | 5–10 partner shelters, measure activation and retention |
| Public launch | — | Both platforms, organic social engine running |

---

## 13. Validation before building

Do this before writing production code. Total cost: a few hundred dollars and about a month.

**1. The manual concierge test.** Recruit 30–50 pet owners. Send them one enrichment activity per day by text or email, hand-picked, for 30 days. No app. Measure: what percentage do the activity, how does that decay over four weeks, which categories perform, and do they ask you to keep going when it ends.

This is the single highest-value experiment available. If daily manual delivery doesn't hold attention, an app won't either.

**2. Landing page test.** Describe the product, take email signups, run a small paid test against dog and cat audiences separately. Measures both demand and the relative pull of the cat wedge.

**3. Shelter conversations.** Talk to five shelter directors. Would they include an access code in adoption packets? This channel is central to the plan and is worth de-risking early.

**4. Willingness-to-pay probe.** In the concierge test, at day 30, ask what they'd pay. Watch for the gap between stated and revealed preference — offer an actual paid continuation and see who converts.

### Success metrics once live

| Metric | Why it matters | Target to beat |
|---|---|---|
| D7 / D30 / D90 retention | The whole thesis | D30 > 40% is a real signal |
| Activities completed per active week | Is the loop working | > 3 |
| Photo attach rate | Emotional engagement proxy | > 30% of completions |
| Swap rate ("not today") | Recommendation quality | < 25% |
| Free → paid conversion | Business viability | > 5% |
| Shelter code activation rate | Channel viability | > 20% |

Track **cumulative activities per user**, never streaks — internally as well as externally. Measuring streaks internally leads to shipping streaks eventually.

---

## 14. Open questions and risks

**Product**
- Does the daily-prompt model retain, or does it decay like every other habit app? (The concierge test answers this.)
- Is one activity a day the right cadence, or should it be 3–4 per week? Some enrichment educators suggest daily; some suggest variety over frequency.
- Do multi-pet households want one activity per pet per day, or one household activity? This meaningfully affects the core loop.

**Content**
- How fast do users exhaust 200 activities? Directly determines content spend.
- Can illustration carry the instructional load, or do some activities genuinely require video?

**Market**
- Is cat-first marketing the right wedge, or does it cap the addressable audience too early?
- Will shelters actually distribute codes, or does it die in operational friction?

**Business**
- Is $5.99/month achievable, or does the pet app category cap closer to $3?
- Does a big pet brand enter this space in the next 24 months?

**Ethical / safety**
- Every activity must be safety-reviewed. Supervision requirements, choking hazards, resource-guarding contraindications, and food-allergy considerations need to be explicit in the content schema and surfaced in the UI.
- The product must never present itself as veterinary or behavioral advice. Behavior problems that appear in onboarding should route toward professional consultation, not just toward more enrichment.

---

## 15. Appendix: research sources consulted

Enrichment domain and taxonomy: ASPCA canine DIY enrichment guidance, Purina enrichment content, Preventive Vet, PetSuites enrichment categories, Jacksonville Humane Society DIY guides, Animal Friends enrichment resources, Wear Wag Repeat.

Competitive scan: DogCat App / Pet Care Tracker (Google Play), myPurina, Woofsie activity deck, Soda Pup and Lickimat product categories.

Habit-formation and comparable-category evidence: BJ Fogg's Tiny Habits, kaizen literature, Couch to 5K dropout research, streak-mechanic criticism across habit-tracking products, Bend and Pliability as examples of content-led growth in an adjacent daily-practice category.

Full search transcripts and the reasoning that eliminated eleven other candidate ideas are available in the originating conversation.
