# Hotel Room Booking

Flutter hotel booking app for the **Raintech Software Limited** coding assessment.

Guests pick stay dates, choose a room, confirm the booking, and complete a **demo payment**. Room data is hardcoded. There is no backend and no real payment gateway.

Booking rules live in `BookingProvider`. Date math lives in `DateHelper`. Screens only read that state and call provider methods.

## How to run (Web)

**Prerequisite:** Flutter SDK (Dart SDK `^3.12.2`)

This project is set up for **Flutter Web**. Chrome is the default target.

```bash
flutter pub get
flutter run -d chrome
```

Production web build (output: `build/web`):

```bash
flutter build web
```

| Command | Use |
| --- | --- |
| `flutter run -d chrome` | Run in Chrome |
| `flutter run -d edge` | Run in Edge (optional) |
| `flutter build web` | Production web build |
| `flutter test` | Unit tests |
| `flutter analyze` | Static analysis |

After structural or asset changes, use a **hot restart**, not only a hot reload.

`main.dart` creates `BookingProvider(enableLocalStorage: true)` and calls `loadSavedBookings()`, so the app uses SharedPreferences (including in the browser). Tests create the provider with a fixed `now` and leave storage off.

### Android (optional)

Android is supported but not required to review the app.

```bash
flutter run
flutter build apk
```

## App flow

1. **Dashboard** — Book a Room, Booking History, total / occupied / available rooms today, stored booking count, last 3 bookings
2. **Booking** — check-in, check-out, guest count, filtered available rooms, nights, and total
3. **Confirm booking** — stay summary, optional ID-proof file name, demo payment method, Complete payment
4. **Success** — last confirmed booking (reference, room, dates, payment, total). Returns to the dashboard after 4 seconds, or immediately with **Back to dashboard**
5. **History** — all stored bookings, newest first

`Continue to confirmation` does not save the booking. `Complete payment` is the only call to `confirmBooking()`. Payment is a local demo. No money is collected.

After confirm, the draft form is cleared (dates, room, guests back to 2, proof cleared, payment back to Cash). `lastConfirmed` is kept so the success screen can show the result.

## Rooms

Hardcoded in `lib/data/room_data.dart`. Rooms are equal by `roomCode`.

| Code | Type | Price / night | Max guests | Image |
| --- | --- | --- | --- | --- |
| R101, R102 | Deluxe Room | ₹3,500 | 2 | `deluxe_room.png` |
| R201, R202 | Executive Suite | ₹5,800 | 3 | `executive_suite.png` |
| R301 | Family Room | ₹4,200 | 4 | `family_room.png` |

Seed booking so availability can be tested before the user books anything:

- **R101** — 20 Sep 2026 to 22 Sep 2026 (2 nights, ₹7,000)
- Reference `BK-R101-20092026`
- Payment: Cash

If local storage is empty, this seed list is written to SharedPreferences. If storage already has data, that list is loaded instead.

## Date logic

`DateHelper` treats every date as a calendar day. Hours and minutes are stripped with `dateOnly`, so 15 Sep 18:45 and 15 Sep 00:00 are the same day.

| Rule | How it works |
| --- | --- |
| Compare days | `dateOnly(a).compareTo(dateOnly(b))` |
| Nights | `checkout.difference(checkIn).inDays` after both dates are date-only |
| Invalid nights | `null` when a date is missing or nights are `<= 0` (same day or checkout before check-in) |
| Display | `15 Sep 2026` |
| Overlap | half-open: `startA < endB` and `startB < endA` |
| Checkout day | free for the next check-in. A stay 20–22 Sep does not block a new check-in on 22 Sep |

Example: R101 booked 20–22 Sep is blocked for 21–23 Sep, and free for 22–24 Sep.

## Booking and price logic

`BookingProvider` owns the draft stay and the saved list.

**Dates**

- Check-in and check-out are stored as date-only values
- `today` comes from an injectable `now` function (`DateTime.now` in the app)
- Check-in on today is valid. Check-in before today is not
- Changing either date clears confirmation and drops the selected room if that room now overlaps a stored booking

**Guests**

- Allowed range is 1 to 4. Default is 2
- `setGuestCount` clamps the value. Increment and decrement use the same method
- A room is listed only when `maxGuests >= guestCount`
- If the selected room can no longer host the new count, the room selection is cleared

**Available rooms**

A room is shown when both are true:

1. It can host the current guest count
2. If dates are valid, it does not overlap a stored booking for the same `roomCode`

Overlap is not applied until both dates are valid. `selectRoom` ignores a room that is already booked for the chosen dates.

**Nights and total**

- `numberOfNights` is `nightsBetween(checkIn, checkOut)` only when dates are valid (not past, and nights exist)
- `totalPrice` is `nights × selectedRoom.pricePerNight`
- Total is `null` until a room is selected
- If dates later become invalid, nights and total become `null` so a stale or negative price is not shown

**Dashboard stats**

- Total rooms: 5
- Occupied today: unique room codes whose stored stay overlaps `[today, tomorrow)`
- Available today: `total rooms − occupied`
- Stored bookings: length of the saved list
- Recent bookings: newest 3 from history

## Validation

`isBookingValid` is true only when `validationMessage` is `null`. Checks run in this order:

1. `Please select a check-in date.`
2. `Check-in date cannot be in the past.`
3. `Please select a check-out date.`
4. `Check-out date must be after check-in date.` (same day or earlier)
5. `Please select a room.`

The UI shows that message. Date pickers can hide some invalid days, but the provider does not depend on the picker.

`confirmBooking()` returns without saving when the draft is invalid or already confirmed.

## Confirm, payment, and storage

On **Complete payment** the provider:

1. Builds a reference `BK-{roomCode}-{dd}{mm}{yyyy}` from the check-in date (example: R101 on 15 Sep 2026 → `BK-R101-15092026`)
2. Saves a `ConfirmedBooking` (room, guests, dates, nights, total, optional proof file name, payment method)
3. Appends it to the in-memory list
4. Sets `lastConfirmed` and `isConfirmed`
5. Resets the draft form
6. Writes the full list to SharedPreferences when storage is enabled

Payment methods: **Cash**, **Credit Card**, **UPI**. Default is Cash. This is a demo flag only.

ID proof: `file_picker` accepts `pdf`, `png`, `jpg`, `jpeg`. Only the file name is stored, not the file bytes.

Storage key: `hotel_confirmed_bookings`. The list is JSON encoded through `ConfirmedBooking.encodeList` / `decodeList`.

Changing dates, room, or guest count after a confirm clears `isConfirmed` and `lastConfirmed` so the next draft is not treated as already paid.

## Features

- Hardcoded room list with local photos
- Check-in and check-out date pickers
- Guest count filter and capacity clear
- Half-open overlap so checkout day can be reused
- Night count and INR total
- Validation messages from the provider
- Optional ID-proof file name
- Demo payment on the confirmation screen
- Local persistence on Android and Web
- Dashboard occupancy and history
- Provider (`ChangeNotifier`) for shared booking state
- Unit tests for the rules above

## Dependencies

| Package | Use |
| --- | --- |
| `provider` | Shared `BookingProvider` state |
| `shared_preferences` | Persist confirmed bookings |
| `file_picker` | Optional ID-proof file name |

## Project structure

```text
lib/
  main.dart                         App entry, theme, Provider + local storage
  data/room_data.dart               Hardcoded rooms and seed booking
  models/hotel_room.dart            Room model (equality by roomCode)
  models/confirmed_booking.dart     Saved booking + JSON encode/decode
  providers/booking_provider.dart   Dates, filter, validation, price, confirm, storage
  screens/dashboard_screen.dart     Stats and navigation
  screens/booking_screen.dart       Dates, guests, rooms, nights, total
  screens/booking_confirm_screen.dart  Summary, proof, payment
  screens/booking_success_screen.dart  lastConfirmed details
  screens/booking_history_screen.dart  Newest-first history
  utils/date_helper.dart            Date-only compare, nights, overlap, display
assets/images/                      Room photos
test/booking_provider_test.dart     Booking logic tests
```

## Architecture

```text
UI screens
    ↓
BookingProvider (ChangeNotifier)
    ↓
HotelRoom + ConfirmedBooking + hardcoded room data
    ↓
DateHelper
```

Widgets do not calculate nights, totals, overlap, or validation themselves.

## Tests

```bash
flutter test
```

`BookingProvider(now: () => DateTime(2026, 9, 14))` is used so "today" is always 14 September 2026. Local storage is disabled.

Covered cases:

- one-night and multi-night totals (Deluxe ₹3,500 × 3 = ₹10,500; Executive ₹5,800 × 2 = ₹11,600)
- time of day ignored when dates are selected
- same-day and reversed dates
- past check-in rejected; check-in today allowed
- missing check-in, check-out, or room
- stale nights/total cleared when dates become invalid
- guest filter (4 guests → only R301)
- selected room cleared when guest count exceeds capacity
- seed overlap blocks R101 for 21–23 Sep; allows R101 from 22 Sep
- confirm builds `BK-R101-15092026`, resets the form, stores Cash by default
- optional proof file name and UPI are saved
- incomplete booking is not confirmed
- a confirmed room is hidden when the same dates are chosen again
- choosing dates after confirm returns to draft state
