# Install Jason Wade's TRIM IT profile picture (PLAY)

**What:** set the landing-page profile photo for **Jason Wade — UserID 9, ProfileID 5** (currently `art/profilepictures/blank.png`).

## Two steps (both on PLAY)
1. **Drop the image file** into the TRIM IT webroot profile-pictures folder (both webroots per the dual-webroot scheme):
   - File: `jwade001.jpg` (520×400 JPEG, pre-cropped to the 130×100 landscape box)
   - Destination: `...\<webroot>\art\profilepictures\jwade001.jpg`
2. **Point the profile at it** (SQL, GSTS DB on play):
   ```sql
   UPDATE dbo.Profiles
   SET    ProfilePicturePath = 'art/profilepictures/jwade001.jpg'
   WHERE  UserID = 9;   -- Jason Wade, ProfileID 5
   ```

## Verify
- Reload the TRIM IT landing page (`Profile$Main`) as Jason → the avatar box (top-left) shows the photo instead of blank.
- Rollback: `UPDATE dbo.Profiles SET ProfilePicturePath = 'art/profilepictures/blank.png' WHERE UserID = 9;`

## Notes
- Naming follows the existing convention (`sgriffiths002.jpg`, `jgriffiths003.jpg`, …).
- The landing page renders it in a fixed 130×100 `<img>`; the file is 520×400 (same 13:10 aspect) so it stays crisp.
- Backup-first: if overwriting an existing `jwade001.jpg`, keep a `.bak`.
