# Course counters backfill

Recounts `lessonsCount` and `testsCount` for every course from its real items
(`Courses/{id}/Sections/{sid}/Items`). Videos and files count as lessons, tests
as tests, the same rule the app uses when an item is added. It also fixes the
teacher's copy in `Users/{teacherId}/Courses/{id}` when it exists. Student
enrollment copies are left as they are.

## Run

1. Firebase console > Project settings > Service accounts > Generate new private key.
   Keep the file outside the repo and never commit it.
2. Install and run a dry run first (Node 18+):

   ```bash
   cd scripts/course-counters-backfill
   npm install
   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json npm run dry-run
   ```

   PowerShell: `$env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\key.json"; npm run dry-run`

3. Check the lines marked `*`, then write the fixes:

   ```bash
   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json npm run apply
   ```

   One course only: `node backfill-course-counters.mjs --course=<courseId> --apply`

Run it when teachers are not adding content: an item added while the script
runs can leave that course off by one.
