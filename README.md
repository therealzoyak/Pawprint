# Pawprint

Pawprint (originally developed under the working name Sniff) includes two local implementations, kept side by side:

- `Sniff.xcodeproj`: the native iOS 17+ SwiftUI milestone 0/1 application
- `index.html` and `sniff-prototype.html`: the original dependency-free web MVP and design prototype

## Native iOS app

Open `Sniff.xcodeproj` in Xcode 16 or newer, select an iOS 17+ simulator, and run the `Sniff` scheme. The app uses SwiftData locally. Ask Fetch connects to the optional Python AI service described below.

The native slice includes dog/cat onboarding, multi-pet switching, a typed reviewed seed catalog, hard safety and materials filtering, explainable preference-aware daily recommendations, full instructions, four completion reactions, optional photo selection, favorites, a filterable safe library, a cumulative memory scrapbook with pet-centered observed preferences, and Fetch, an OpenAI-powered pet-aware copilot. The phone safety-filters candidate activities first; the AI can understand a natural-language request and choose only from those reviewed candidates. Unit tests cover catalog decoding, safety filtering, reaction effects, rotation, recent avoidance, calming bias, swap state, pet isolation, filters, and safe recommendation output.

### Run Ask Fetch AI

Keep `OPENAI_API_KEY` on the Python server; never add it to the iOS app or commit it.

```sh
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Put your key in .env, then export it into the process:
set -a; source .env; set +a
uvicorn app:app --reload
```

The simulator uses `http://127.0.0.1:8000` by default. For a physical device or production, set the `FETCH_AI_BASE_URL` Xcode build setting to the HTTPS URL of the deployed Python service. The backend defaults to `gpt-5.6-terra`; set `OPENAI_MODEL` to change it.

Run tests from Xcode or with:

```sh
xcodebuild test -project Sniff.xcodeproj -scheme Sniff -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Web MVP

Sniff gives a pet owner one short, suitable enrichment activity each day. This dependency-free web MVP is based on the accompanying product brief and design prototype.

## Run it

Start a local static-file server in this directory:

```sh
python3 -m http.server 4173
```

Then visit `http://localhost:4173`.

## Included

- Dog/cat onboarding and pet preferences
- Rules-based daily activity selection with safety and materials filtering
- Activity swaps, instructions, safety notes, and favorites
- Completion reactions that influence later recommendations
- A persistent scrapbook and filterable activity library
- Browser persistence through local storage
- A structured 1,000-activity catalog spanning 19 pet species
- Deterministic daily matching by species, intensity, attention needs, materials, safety flags, feedback, and recent history

## Activity data

The imported catalog lives in `activities-data.js`. Every record retains the source list number, species, energy tier, inferred category, materials, instructions, and a safety note so recommendations can be traced back to the supplied list.

This is a local MVP. Accounts, cloud sync, real photo uploads, push notifications, payments, analytics, and a content-management system still require a backend/mobile implementation.
