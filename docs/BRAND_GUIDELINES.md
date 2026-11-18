# SmartRoute Uganda — Brand Guidelines

## Product Identity

**Product name:** SmartRoute Uganda  
**Tagline:** Beyond Navigation. Towards Smarter Mobility.  
**Market:** Kampala, Uganda · Expanding to Uganda, then East Africa

---

## Logo

The SmartRoute Uganda logo contains:
- A stylised bird/eagle-inspired symbol with intersecting route and direction shapes
- A road-like central path
- Electric lime / yellow-green, signal cyan and white colouring
- The "SmartRoute Uganda" wordmark

**Logo asset:** `assets/brand/smartroute_original.png.png`

### Logo Usage Rules

| Context | Treatment |
|---|---|
| Authentication screens | Full logo with wordmark, centred |
| App bar (wide layout) | Full logo, constrained height |
| Navigation rail | Full logo, contained in sidebar header |
| Dark backgrounds | Logo on transparent/dark surface — do not add a background rectangle |
| Light backgrounds | Logo on light surface with appropriate contrast |

**Never:**
- Stretch or distort the logo's aspect ratio
- Redraw or reinterpret the logo artwork
- Place the logo on colours that reduce legibility
- Add a permanent background rectangle to a transparent logo

---

## Colour Palette

| Token | Hex | Usage |
|---|---|---|
| Obsidian | `#090E18` | Primary dark background |
| Deep Space Navy | `#111B2A` | Dark surface, card backgrounds |
| Electric Lime | `#B6FF3B` | Primary action, selected route, key highlights |
| Signal Cyan | `#26D9E8` | Alternative route, information, secondary highlights |
| Cloud White | `#F4F7FB` | Light background |
| Pure White | `#FFFFFF` | Cards, inputs (light theme) |
| Graphite | `#273449` | Secondary dark surface |
| Dark Card | `#1C2B42` | Card background (dark) |
| Dark Border | `#2A3D57` | Borders (dark) |
| Dark Muted | `#6B82A0` | Secondary text (dark) |
| Light Border | `#E2E8F0` | Borders (light) |
| Light Muted | `#64748B` | Secondary text (light) |
| Hazard Red | `#FF3B3B` | Accidents, closures, urgent warnings |
| Caution Amber | `#FFB830` | Roadworks, moderate congestion, caution |
| Success Green | `#22C55E` | Clear conditions, verified states |
| Info Blue | `#3B82F6` | Informational content, flooding |

### Colour Usage Principles

- **Lime** = primary action, identity, selected state
- **Cyan** = secondary information, alternatives
- **Navy/Obsidian** = premium dark surfaces — use generously in dark theme
- **White/Cloud** = clean light surfaces
- **Red** = hazards, closures, urgent — use sparingly for genuine severity
- **Amber** = caution — moderate conditions, roadworks
- **Green** = safe, confirmed, verified

**Premium restraint:** Never fill surfaces with neon colours. Use hierarchy and breathing room.

---

## Typography

| Role | Font | Weight | Size |
|---|---|---|---|
| Display headings | Space Grotesk | 700 | 26–32px |
| Section headings | Space Grotesk | 600 | 15–22px |
| Body text | Inter | 400 | 14–16px |
| Labels / buttons | Inter | 500–600 | 11–14px |
| Technical values | JetBrains Mono | 400–500 | 12–18px |

Fonts are loaded via `google_fonts` package. Fonts are cached locally after first load.

### Typography Usage

- **Space Grotesk**: All prominent headings, dashboard titles, display text
- **Inter**: All body copy, labels, captions, navigation items, form fields
- **JetBrains Mono**: Route identifiers, distance/time values, UGX amounts, SmartScore values

---

## Iconography

Use Material Icons for all interface iconography. Icon categories used:

- **Navigation**: `alt_route`, `navigation`, `route`, `directions_car`
- **Traffic**: `traffic`, `warning_amber`, `block`, `construction`
- **Reports**: `report`, `report_problem`, `car_crash`, `water`, `dangerous`
- **Location**: `location_on`, `my_location`, `map`, `place`
- **Vehicle**: `directions_car`, `two_wheeler`, `local_shipping`, `airport_shuttle`
- **Fuel**: `local_gas_station`, `payments`
- **Community**: `check_circle`, `thumb_up`, `campaign`, `emoji_events`
- **Account**: `person`, `business`, `settings`, `logout`

---

## Visual Direction: Futuristic Intelligence

- **Premium dark-first** design: the dark theme should feel like a premium navigation product
- **Controlled gradients** on hero cards only (navy-to-graphite)
- **Subtle borders** rather than heavy drop shadows
- **Animated transitions** that feel fluid and fast — never sluggish
- **Data-first** layouts: clear hierarchy where numbers and status are always prominent

---

## Themes

**Light theme:** Cloud White background, pure white cards, deep navy text, lime accents  
**Dark theme:** Obsidian background, deep navy cards, cloud white text, lime accents  
**System default:** Follows device preference

Theme switching: `ThemeProvider` (Provider) with `SharedPreferences` persistence.
