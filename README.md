# Sniff MVP

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
