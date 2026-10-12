BEGIN;
--
-- Create model Course
--
CREATE TABLE "core_course" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "description_uk" text NOT NULL, "description_en" text NOT NULL, "level" smallint unsigned NOT NULL CHECK ("level" >= 0), "duration_hours" smallint unsigned NOT NULL CHECK ("duration_hours" >= 0), "format" varchar(4) NOT NULL, "is_published" bool NOT NULL);
--
-- Create model Interest
--
CREATE TABLE "core_interest" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "key" varchar(50) NOT NULL UNIQUE, "name_uk" varchar(80) NOT NULL, "name_en" varchar(80) NOT NULL);
--
-- Create model Skill
--
CREATE TABLE "core_skill" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "key" varchar(50) NOT NULL UNIQUE, "name_uk" varchar(80) NOT NULL, "name_en" varchar(80) NOT NULL);
--
-- Create model Enrollment
--
CREATE TABLE "core_enrollment" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "started_at" datetime NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Add field category to course
--
CREATE TABLE "new__core_course" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "description_uk" text NOT NULL, "description_en" text NOT NULL, "level" smallint unsigned NOT NULL CHECK ("level" >= 0), "duration_hours" smallint unsigned NOT NULL CHECK ("duration_hours" >= 0), "format" varchar(4) NOT NULL, "is_published" bool NOT NULL, "category_id" bigint NOT NULL REFERENCES "core_interest" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "new__core_course" ("id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id") SELECT "id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", NULL FROM "core_course";
DROP TABLE "core_course";
ALTER TABLE "new__core_course" RENAME TO "core_course";
CREATE UNIQUE INDEX "core_enrollment_user_id_course_id_0fb0d47c_uniq" ON "core_enrollment" ("user_id", "course_id");
CREATE INDEX "core_enrollment_course_id_fe1f9f12" ON "core_enrollment" ("course_id");
CREATE INDEX "core_enrollment_user_id_676c05fa" ON "core_enrollment" ("user_id");
CREATE INDEX "core_course_category_id_6eee1bdf" ON "core_course" ("category_id");
--
-- Add field interests to course
--
CREATE TABLE "core_course_interests" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "interest_id" bigint NOT NULL REFERENCES "core_interest" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model Module
--
CREATE TABLE "core_module" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "order" smallint unsigned NOT NULL CHECK ("order" >= 0), "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model Notification
--
CREATE TABLE "core_notification" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "code" varchar(20) NOT NULL, "is_read" bool NOT NULL, "created_at" datetime NOT NULL, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model Profile
--
CREATE TABLE "core_profile" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "display_name" varchar(60) NOT NULL, "goal" varchar(2) NOT NULL, "weekly_hours" smallint unsigned NOT NULL CHECK ("weekly_hours" >= 0), "preferred_format" varchar(4) NOT NULL, "reminders" bool NOT NULL, "user_id" integer NOT NULL UNIQUE REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE TABLE "core_profile_interests" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "profile_id" bigint NOT NULL REFERENCES "core_profile" ("id") DEFERRABLE INITIALLY DEFERRED, "interest_id" bigint NOT NULL REFERENCES "core_interest" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model CourseSkill
--
CREATE TABLE "core_courseskill" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "order" smallint unsigned NOT NULL CHECK ("order" >= 0), "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Add field skills to course
--
CREATE TABLE "new__core_course" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "description_uk" text NOT NULL, "description_en" text NOT NULL, "level" smallint unsigned NOT NULL CHECK ("level" >= 0), "duration_hours" smallint unsigned NOT NULL CHECK ("duration_hours" >= 0), "format" varchar(4) NOT NULL, "is_published" bool NOT NULL, "category_id" bigint NOT NULL REFERENCES "core_interest" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "new__core_course" ("id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id") SELECT "id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id" FROM "core_course";
DROP TABLE "core_course";
ALTER TABLE "new__core_course" RENAME TO "core_course";
CREATE UNIQUE INDEX "core_course_interests_course_id_interest_id_e6b15044_uniq" ON "core_course_interests" ("course_id", "interest_id");
CREATE INDEX "core_course_interests_course_id_3ad05d74" ON "core_course_interests" ("course_id");
CREATE INDEX "core_course_interests_interest_id_966cfbb0" ON "core_course_interests" ("interest_id");
CREATE INDEX "core_module_course_id_2aa5c263" ON "core_module" ("course_id");
CREATE INDEX "core_notification_user_id_6e341aac" ON "core_notification" ("user_id");
CREATE UNIQUE INDEX "core_profile_interests_profile_id_interest_id_121c02f1_uniq" ON "core_profile_interests" ("profile_id", "interest_id");
CREATE INDEX "core_profile_interests_profile_id_049b9d41" ON "core_profile_interests" ("profile_id");
CREATE INDEX "core_profile_interests_interest_id_9944bc46" ON "core_profile_interests" ("interest_id");
CREATE UNIQUE INDEX "core_courseskill_course_id_skill_id_405f690f_uniq" ON "core_courseskill" ("course_id", "skill_id");
CREATE INDEX "core_courseskill_course_id_5c9ae85a" ON "core_courseskill" ("course_id");
CREATE INDEX "core_courseskill_skill_id_d2bf5dfb" ON "core_courseskill" ("skill_id");
CREATE INDEX "core_course_category_id_6eee1bdf" ON "core_course" ("category_id");
--
-- Create model ModuleProgress
--
CREATE TABLE "core_moduleprogress" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "completed_at" datetime NOT NULL, "enrollment_id" bigint NOT NULL REFERENCES "core_enrollment" ("id") DEFERRABLE INITIALLY DEFERRED, "module_id" bigint NOT NULL REFERENCES "core_module" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model RecentView
--
CREATE TABLE "core_recentview" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "viewed_at" datetime NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model SavedCourse
--
CREATE TABLE "core_savedcourse" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "created_at" datetime NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model Prerequisite
--
CREATE TABLE "core_prerequisite" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "min_level" smallint unsigned NOT NULL CHECK ("min_level" >= 0), "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED);
--
-- Create model UserSkill
--
CREATE TABLE "core_userskill" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "current_level" smallint unsigned NOT NULL CHECK ("current_level" >= 0), "desired_level" smallint unsigned NOT NULL CHECK ("desired_level" >= 0), "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED);
CREATE UNIQUE INDEX "core_moduleprogress_enrollment_id_module_id_3546586a_uniq" ON "core_moduleprogress" ("enrollment_id", "module_id");
CREATE INDEX "core_moduleprogress_enrollment_id_a59bb152" ON "core_moduleprogress" ("enrollment_id");
CREATE INDEX "core_moduleprogress_module_id_a907287f" ON "core_moduleprogress" ("module_id");
CREATE UNIQUE INDEX "core_recentview_user_id_course_id_5c785a04_uniq" ON "core_recentview" ("user_id", "course_id");
CREATE INDEX "core_recentview_course_id_1c17ec2b" ON "core_recentview" ("course_id");
CREATE INDEX "core_recentview_user_id_610abd03" ON "core_recentview" ("user_id");
CREATE UNIQUE INDEX "core_savedcourse_user_id_course_id_5ec9a98c_uniq" ON "core_savedcourse" ("user_id", "course_id");
CREATE INDEX "core_savedcourse_course_id_cd911f0b" ON "core_savedcourse" ("course_id");
CREATE INDEX "core_savedcourse_user_id_d535cf16" ON "core_savedcourse" ("user_id");
CREATE UNIQUE INDEX "core_prerequisite_course_id_skill_id_cbb2ed7a_uniq" ON "core_prerequisite" ("course_id", "skill_id");
CREATE INDEX "core_prerequisite_course_id_31684edf" ON "core_prerequisite" ("course_id");
CREATE INDEX "core_prerequisite_skill_id_8791abd4" ON "core_prerequisite" ("skill_id");
CREATE UNIQUE INDEX "core_userskill_user_id_skill_id_8fe1cd4b_uniq" ON "core_userskill" ("user_id", "skill_id");
CREATE INDEX "core_userskill_skill_id_b5a74b63" ON "core_userskill" ("skill_id");
CREATE INDEX "core_userskill_user_id_9ea46a66" ON "core_userskill" ("user_id");
COMMIT;
