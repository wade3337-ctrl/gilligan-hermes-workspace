# Deploy Package — TRIM IT Location Lat/Long geocoder fix

**Date:** 2026-07-22
**Prepared for:** Travis Walters (DB) · Jordan / IT Support
**Resolves:** Rosa Smith's "HIGH PRIORITY — Lat/Long Bug" (Location tab coordinates saving as 0/0)
**Change type:** ONE SQL stored procedure. **No webroot / IIS / .cfm files change.**

---

## TL;DR
TRIM IT auto-populates a Location's map coordinates from its address using a database routine
(`dbo.Locations_LatLong_upr`, fired by the `LocationsPostUpdateAddress` trigger). That routine geocoded
by calling **Google's old keyless geocoding endpoint**, which **Google shut off** — so the call silently
fails and new/edited locations save as **0 / 0** (map pin lands in the ocean). This rewrites that one
routine to use the **free U.S. Census geocoder** (HTTPS, no API key, no billing). Then a one-time
**backfill** fixes the locations already stuck at 0/0.

> Note: this is NOT a permissions problem. Rosa's email also asked to "grant admin permission to add
> lat/long manually" — that isn't needed; the affected staff already have the Inventory Admin role. The
> real cause was the dead geocoder.

---

## Root cause (for reference)
- Proc `dbo.Locations_LatLong_upr` built this URL and called it via SQL OLE automation:
  `http://maps.google.com/maps/api/geocode/xml?sensor=false&address=...`
  Google retired keyless geocoding, so the request no longer returns coordinates → the proc wrote nothing
  (and its old `RAISERROR` on failure could abort the whole Location save).
- Geocoding is centralized: the same proc is used by **address edits, new-site creation, RFP generation,
  and the nightly batch** — so fixing this one proc fixes every path.

---

## Files in this package
| File | Purpose |
|---|---|
| `Locations_LatLong_upr.PROD-ALTER.sql` | **The fix** — ALTER of the proc to use the Census geocoder. |
| `backfill-0-0-locations.sql` | One-time backfill of locations currently at 0/0. |
| `Locations_LatLong_upr.ROLLBACK.sql` | Restores the exact original proc if needed. |
| `Locations_LatLong_upr.ORIGINAL.sql` | Verbatim original proc definition (backup of record). |

---

## PREREQUISITE (Travis — confirm on prod first)
The proc makes its HTTPS call via SQL Server OLE automation, so this must be ON (it already was on prod —
it's how the geocoder always ran):
```sql
SELECT name, value_in_use FROM sys.configurations WHERE name = 'Ole Automation Procedures';  -- expect 1
```
If it's `0`, enable it:
```sql
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1; RECONFIGURE;
```

## DEPLOY (Travis — prod DB `GSTS`)
1. **Back up current proc** (belt-and-suspenders): script out `dbo.Locations_LatLong_upr` as-is, or keep
   `Locations_LatLong_upr.ORIGINAL.sql` from this package.
2. **Apply the fix:** run `Locations_LatLong_upr.PROD-ALTER.sql`.
3. **Smoke test** on a single known-bad location (pick any Location showing 0/0), replacing `<ID>`:
   ```sql
   EXEC dbo.Locations_LatLong_upr @ZLocationID = <ID>;
   SELECT LocationID, Street, City, Latitude, Longitude FROM dbo.Locations WHERE LocationID = <ID>;
   ```
   Expect real coordinates (not 0/0).
4. **Backfill** the existing 0/0 locations: run `backfill-0-0-locations.sql`.
   - Default = **all** 0/0 locations with a street address.
   - For a **cautious first pass**, use the `TOP (N)` variant noted in the script (process a small batch,
     verify, then run again — already-fixed rows drop out automatically).
   - The script prints how many it processed and how many remain at 0/0 (those are addresses Census couldn't
     match — usually a typo/PO-box; they fix themselves once the address is corrected and re-saved).

## VERIFY (Travis + Jordan)
- Open a previously-0/0 Location in TRIM IT → the **Latitude/Longitude** field shows real numbers and the
  map pin sits on the property (not the ocean).
- Edit an address and Save → coordinates re-populate automatically.

## ROLLBACK (Travis)
Run `Locations_LatLong_upr.ROLLBACK.sql` (restores the exact original proc). No data migration to undo;
backfilled coordinates can stay (they're correct) or be reset to 0 if desired.

---

## For Jordan / IT
- **Nothing to deploy in IIS / the webroot** — this is a database-only change. No `.cfm`, no app restart.
- This closes Rosa's Lat/Long ticket. The "grant admin permission to add lat/long manually" interim in her
  email is **not required** (staff already hold the Inventory Admin role; the field was blank because the
  geocoder was dead, not because of permissions).
- Only environmental dependency: `Ole Automation Procedures = 1` on the prod SQL Server (see prerequisite).

---

## Verification already done (on the play server)
- Rewritten proc tested on play against three locations that were stuck at 0/0:
  - 10985 Oleander Ave, Fontana → `34.0542 / -117.4486`
  - 14825 S Avalon Blvd, Gardena → `33.8974 / -118.2653`
  - 20 City Blvd W, Orange → `0/0 → 33.7824 / -117.8899` (via the address-edit trigger path)
- Note: play had `Ole Automation Procedures` OFF; it was enabled there for testing. Confirm it's ON on prod.
