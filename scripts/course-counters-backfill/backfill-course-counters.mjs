import { readFileSync } from 'node:fs';
import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const LESSON_TYPES = new Set(['Vedio', 'File']);
const TEST_TYPE = 'Test';

const args = process.argv.slice(2);
const apply = args.includes('--apply');
const onlyCourse = args.find((arg) => arg.startsWith('--course='))?.slice('--course='.length);

const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
if (!keyPath) {
  console.error('Set GOOGLE_APPLICATION_CREDENTIALS to the path of a Firebase service account JSON file.');
  process.exit(1);
}

initializeApp({ credential: cert(JSON.parse(readFileSync(keyPath, 'utf8'))) });
const db = getFirestore();

async function countItems(courseRef) {
  const sections = await courseRef.collection('Sections').get();
  const counts = { sections: sections.size, lessons: 0, tests: 0, unknown: 0 };
  for (const section of sections.docs) {
    const items = await section.ref.collection('Items').select('type').get();
    for (const item of items.docs) {
      const type = item.get('type');
      if (type === TEST_TYPE) counts.tests++;
      else if (LESSON_TYPES.has(type)) counts.lessons++;
      else counts.unknown++;
    }
  }
  return counts;
}

async function loadCourses() {
  if (onlyCourse) return [await db.collection('Courses').doc(onlyCourse).get()];
  return (await db.collection('Courses').get()).docs;
}

async function fixCourse(course, counts) {
  const update = { lessonsCount: counts.lessons, testsCount: counts.tests };
  const batch = db.batch();
  batch.update(course.ref, update);
  const teacherId = course.get('contentcreaterentity')?.id;
  let mirrorUpdated = false;
  if (teacherId) {
    const mirror = db.collection('Users').doc(teacherId).collection('Courses').doc(course.id);
    if ((await mirror.get()).exists) {
      batch.update(mirror, update);
      mirrorUpdated = true;
    }
  }
  await batch.commit();
  return mirrorUpdated;
}

async function main() {
  const courses = await loadCourses();
  let checked = 0;
  let drifted = 0;
  let fixed = 0;

  for (const course of courses) {
    if (!course.exists) {
      console.warn(`- ${course.id}: not found`);
      continue;
    }
    checked++;
    const counts = await countItems(course.ref);
    const stored = {
      lessons: Number(course.get('lessonsCount') ?? 0),
      tests: Number(course.get('testsCount') ?? 0),
    };
    const drift = stored.lessons !== counts.lessons || stored.tests !== counts.tests;
    const title = course.get('title') ?? '';
    const unknown = counts.unknown ? `, ${counts.unknown} items with an unknown type` : '';
    console.log(
      `${drift ? '*' : ' '} ${course.id} "${title}": lessons ${stored.lessons} -> ${counts.lessons}, ` +
        `tests ${stored.tests} -> ${counts.tests} (${counts.sections} sections${unknown})`,
    );
    if (!drift) continue;
    drifted++;
    if (!apply) continue;
    const mirrorUpdated = await fixCourse(course, counts);
    fixed++;
    console.log(`  updated${mirrorUpdated ? ' (and the teacher copy)' : ''}`);
  }

  console.log(`\nChecked ${checked} courses, ${drifted} with wrong counters.`);
  if (!apply && drifted > 0) console.log('Dry run only. Run again with --apply to write the fixes.');
  if (apply) console.log(`Fixed ${fixed} courses.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
