-- Learnova: SQL-скрипт створення таблиць (згенеровано з міграцій Django).
-- Джерело: python manage.py sqlmigrate core 0001 / core 0002

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

BEGIN;
--
-- Create model AgentKnowledge
--
CREATE TABLE "core_agentknowledge" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "key" varchar(50) NOT NULL UNIQUE, "keywords" varchar(200) NOT NULL, "question_uk" varchar(200) NOT NULL, "question_en" varchar(200) NOT NULL, "answer_uk" text NOT NULL, "answer_en" text NOT NULL, "priority" smallint unsigned NOT NULL CHECK ("priority" >= 0), "hits" integer unsigned NOT NULL CHECK ("hits" >= 0), "is_active" bool NOT NULL);
--
-- Create model ChatMessage
--
CREATE TABLE "core_chatmessage" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "role" varchar(5) NOT NULL, "content" text NOT NULL, "source" varchar(16) NOT NULL, "created_at" datetime NOT NULL);
--
-- Create model ChatSession
--
CREATE TABLE "core_chatsession" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "session_key" varchar(40) NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
--
-- Change Meta options on course
--
-- (no-op)
--
-- Change Meta options on courseskill
--
-- (no-op)
--
-- Change Meta options on enrollment
--
-- (no-op)
--
-- Change Meta options on interest
--
-- (no-op)
--
-- Change Meta options on module
--
-- (no-op)
--
-- Change Meta options on moduleprogress
--
-- (no-op)
--
-- Change Meta options on notification
--
-- (no-op)
--
-- Change Meta options on prerequisite
--
-- (no-op)
--
-- Change Meta options on profile
--
-- (no-op)
--
-- Change Meta options on recentview
--
-- (no-op)
--
-- Change Meta options on savedcourse
--
-- (no-op)
--
-- Change Meta options on skill
--
-- (no-op)
--
-- Change Meta options on userskill
--
-- (no-op)
--
-- Alter unique_together for courseskill (0 constraint(s))
--
DROP INDEX "uniq_course_skill";
--
-- Alter unique_together for enrollment (0 constraint(s))
--
DROP INDEX "uniq_enrollment";
--
-- Alter unique_together for moduleprogress (0 constraint(s))
--
DROP INDEX "uniq_module_progress";
--
-- Alter unique_together for prerequisite (0 constraint(s))
--
DROP INDEX "uniq_course_prereq";
--
-- Alter unique_together for recentview (0 constraint(s))
--
DROP INDEX "uniq_recent_view";
--
-- Alter unique_together for savedcourse (0 constraint(s))
--
DROP INDEX "uniq_saved_course";
--
-- Alter unique_together for userskill (0 constraint(s))
--
DROP INDEX "uniq_user_skill";
--
-- Add field cover_key to course
--
CREATE TABLE "new__core_course" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "description_uk" text NOT NULL, "description_en" text NOT NULL, "level" smallint unsigned NOT NULL CHECK ("level" >= 0), "duration_hours" smallint unsigned NOT NULL CHECK ("duration_hours" >= 0), "format" varchar(4) NOT NULL, "is_published" bool NOT NULL, "category_id" bigint NOT NULL REFERENCES "core_interest" ("id") DEFERRABLE INITIALLY DEFERRED, "cover_key" varchar(32) NOT NULL);
INSERT INTO "new__core_course" ("id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id", "cover_key") SELECT "id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id", '' FROM "core_course";
DROP TABLE "core_course";
ALTER TABLE "new__core_course" RENAME TO "core_course";
CREATE INDEX "core_chatmessage_created_at_d3e617df" ON "core_chatmessage" ("created_at");
CREATE INDEX "core_chatsession_session_key_bf5fe52f" ON "core_chatsession" ("session_key");
CREATE INDEX "core_course_category_id_6eee1bdf" ON "core_course" ("category_id");
CREATE INDEX "core_course_cover_key_321bde95" ON "core_course" ("cover_key");
--
-- Alter field category on course
--
-- (no-op)
--
-- Alter field description_en on course
--
-- (no-op)
--
-- Alter field description_uk on course
--
-- (no-op)
--
-- Alter field duration_hours on course
--
-- (no-op)
--
-- Alter field format on course
--
-- (no-op)
--
-- Alter field interests on course
--
-- (no-op)
--
-- Alter field is_published on course
--
-- (no-op)
--
-- Alter field level on course
--
-- (no-op)
--
-- Alter field skills on course
--
-- (no-op)
--
-- Alter field title_en on course
--
-- (no-op)
--
-- Alter field title_uk on course
--
-- (no-op)
--
-- Alter field course on courseskill
--
-- (no-op)
--
-- Alter field order on courseskill
--
-- (no-op)
--
-- Alter field skill on courseskill
--
-- (no-op)
--
-- Alter field key on interest
--
-- (no-op)
--
-- Alter field name_en on interest
--
-- (no-op)
--
-- Alter field name_uk on interest
--
-- (no-op)
--
-- Alter field order on module
--
-- (no-op)
--
-- Alter field title_en on module
--
-- (no-op)
--
-- Alter field title_uk on module
--
-- (no-op)
--
-- Alter field completed_at on moduleprogress
--
CREATE TABLE "new__core_moduleprogress" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "enrollment_id" bigint NOT NULL REFERENCES "core_enrollment" ("id") DEFERRABLE INITIALLY DEFERRED, "module_id" bigint NOT NULL REFERENCES "core_module" ("id") DEFERRABLE INITIALLY DEFERRED, "completed_at" datetime NOT NULL);
INSERT INTO "new__core_moduleprogress" ("id", "enrollment_id", "module_id", "completed_at") SELECT "id", "enrollment_id", "module_id", "completed_at" FROM "core_moduleprogress";
DROP TABLE "core_moduleprogress";
ALTER TABLE "new__core_moduleprogress" RENAME TO "core_moduleprogress";
CREATE INDEX "core_moduleprogress_enrollment_id_a59bb152" ON "core_moduleprogress" ("enrollment_id");
CREATE INDEX "core_moduleprogress_module_id_a907287f" ON "core_moduleprogress" ("module_id");
CREATE INDEX "core_moduleprogress_completed_at_b982518e" ON "core_moduleprogress" ("completed_at");
--
-- Alter field module on moduleprogress
--
-- (no-op)
--
-- Alter field code on notification
--
CREATE TABLE "new__core_notification" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "is_read" bool NOT NULL, "created_at" datetime NOT NULL, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, "code" varchar(20) NOT NULL);
INSERT INTO "new__core_notification" ("id", "is_read", "created_at", "user_id", "code") SELECT "id", "is_read", "created_at", "user_id", "code" FROM "core_notification";
DROP TABLE "core_notification";
ALTER TABLE "new__core_notification" RENAME TO "core_notification";
CREATE INDEX "core_notification_user_id_6e341aac" ON "core_notification" ("user_id");
CREATE INDEX "core_notification_code_fe90977e" ON "core_notification" ("code");
--
-- Alter field min_level on prerequisite
--
-- (no-op)
--
-- Alter field skill on prerequisite
--
-- (no-op)
--
-- Alter field display_name on profile
--
-- (no-op)
--
-- Alter field goal on profile
--
-- (no-op)
--
-- Alter field interests on profile
--
-- (no-op)
--
-- Alter field preferred_format on profile
--
-- (no-op)
--
-- Alter field reminders on profile
--
-- (no-op)
--
-- Alter field weekly_hours on profile
--
-- (no-op)
--
-- Alter field course on recentview
--
-- (no-op)
--
-- Alter field course on savedcourse
--
-- (no-op)
--
-- Alter field key on skill
--
-- (no-op)
--
-- Alter field name_en on skill
--
-- (no-op)
--
-- Alter field name_uk on skill
--
-- (no-op)
--
-- Alter field current_level on userskill
--
-- (no-op)
--
-- Alter field desired_level on userskill
--
-- (no-op)
--
-- Alter field skill on userskill
--
-- (no-op)
--
-- Create index course_pub_lvl_idx on field(s) is_published, level of model course
--
CREATE INDEX "course_pub_lvl_idx" ON "core_course" ("is_published", "level");
--
-- Create index course_cat_fmt_idx on field(s) category, format of model course
--
CREATE INDEX "course_cat_fmt_idx" ON "core_course" ("category_id", "format");
--
-- Create index courseskill_skill_idx on field(s) skill, order of model courseskill
--
CREATE INDEX "courseskill_skill_idx" ON "core_courseskill" ("skill_id", "order");
--
-- Create index enroll_user_idx on field(s) user, started_at of model enrollment
--
CREATE INDEX "enroll_user_idx" ON "core_enrollment" ("user_id", "started_at");
--
-- Create index notif_user_read_idx on field(s) user, is_read of model notification
--
CREATE INDEX "notif_user_read_idx" ON "core_notification" ("user_id", "is_read");
--
-- Create index recent_user_idx on field(s) user, -viewed_at of model recentview
--
CREATE INDEX "recent_user_idx" ON "core_recentview" ("user_id", "viewed_at" DESC);
--
-- Create index userskill_user_idx on field(s) user, skill of model userskill
--
CREATE INDEX "userskill_user_idx" ON "core_userskill" ("user_id", "skill_id");
--
-- Create constraint course_level_1_3 on model course
--
CREATE TABLE "new__core_course" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "description_uk" text NOT NULL, "description_en" text NOT NULL, "level" smallint unsigned NOT NULL CHECK ("level" >= 0), "duration_hours" smallint unsigned NOT NULL CHECK ("duration_hours" >= 0), "format" varchar(4) NOT NULL, "is_published" bool NOT NULL, "category_id" bigint NOT NULL REFERENCES "core_interest" ("id") DEFERRABLE INITIALLY DEFERRED, "cover_key" varchar(32) NOT NULL, CONSTRAINT "course_level_1_3" CHECK ("level" IN (1, 2, 3)));
INSERT INTO "new__core_course" ("id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id", "cover_key") SELECT "id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id", "cover_key" FROM "core_course";
DROP TABLE "core_course";
ALTER TABLE "new__core_course" RENAME TO "core_course";
CREATE INDEX "core_course_category_id_6eee1bdf" ON "core_course" ("category_id");
CREATE INDEX "core_course_cover_key_321bde95" ON "core_course" ("cover_key");
CREATE INDEX "course_pub_lvl_idx" ON "core_course" ("is_published", "level");
CREATE INDEX "course_cat_fmt_idx" ON "core_course" ("category_id", "format");
--
-- Create constraint course_hours_positive on model course
--
CREATE TABLE "new__core_course" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "description_uk" text NOT NULL, "description_en" text NOT NULL, "level" smallint unsigned NOT NULL CHECK ("level" >= 0), "duration_hours" smallint unsigned NOT NULL CHECK ("duration_hours" >= 0), "format" varchar(4) NOT NULL, "is_published" bool NOT NULL, "category_id" bigint NOT NULL REFERENCES "core_interest" ("id") DEFERRABLE INITIALLY DEFERRED, "cover_key" varchar(32) NOT NULL, CONSTRAINT "course_level_1_3" CHECK ("level" IN (1, 2, 3)), CONSTRAINT "course_hours_positive" CHECK ("duration_hours" > 0));
INSERT INTO "new__core_course" ("id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id", "cover_key") SELECT "id", "title_uk", "title_en", "description_uk", "description_en", "level", "duration_hours", "format", "is_published", "category_id", "cover_key" FROM "core_course";
DROP TABLE "core_course";
ALTER TABLE "new__core_course" RENAME TO "core_course";
CREATE INDEX "core_course_category_id_6eee1bdf" ON "core_course" ("category_id");
CREATE INDEX "core_course_cover_key_321bde95" ON "core_course" ("cover_key");
CREATE INDEX "course_pub_lvl_idx" ON "core_course" ("is_published", "level");
CREATE INDEX "course_cat_fmt_idx" ON "core_course" ("category_id", "format");
--
-- Create constraint uniq_course_skill on model courseskill
--
CREATE TABLE "new__core_courseskill" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "order" smallint unsigned NOT NULL CHECK ("order" >= 0), "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_course_skill" UNIQUE ("course_id", "skill_id"));
INSERT INTO "new__core_courseskill" ("id", "order", "course_id", "skill_id") SELECT "id", "order", "course_id", "skill_id" FROM "core_courseskill";
DROP TABLE "core_courseskill";
ALTER TABLE "new__core_courseskill" RENAME TO "core_courseskill";
CREATE INDEX "core_courseskill_course_id_5c9ae85a" ON "core_courseskill" ("course_id");
CREATE INDEX "core_courseskill_skill_id_d2bf5dfb" ON "core_courseskill" ("skill_id");
CREATE INDEX "courseskill_skill_idx" ON "core_courseskill" ("skill_id", "order");
--
-- Create constraint uniq_enrollment on model enrollment
--
CREATE TABLE "new__core_enrollment" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "started_at" datetime NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_enrollment" UNIQUE ("user_id", "course_id"));
INSERT INTO "new__core_enrollment" ("id", "started_at", "course_id", "user_id") SELECT "id", "started_at", "course_id", "user_id" FROM "core_enrollment";
DROP TABLE "core_enrollment";
ALTER TABLE "new__core_enrollment" RENAME TO "core_enrollment";
CREATE INDEX "core_enrollment_course_id_fe1f9f12" ON "core_enrollment" ("course_id");
CREATE INDEX "core_enrollment_user_id_676c05fa" ON "core_enrollment" ("user_id");
CREATE INDEX "enroll_user_idx" ON "core_enrollment" ("user_id", "started_at");
--
-- Create constraint uniq_course_module_order on model module
--
CREATE TABLE "new__core_module" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "order" smallint unsigned NOT NULL CHECK ("order" >= 0), "title_uk" varchar(160) NOT NULL, "title_en" varchar(160) NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_course_module_order" UNIQUE ("course_id", "order"));
INSERT INTO "new__core_module" ("id", "order", "title_uk", "title_en", "course_id") SELECT "id", "order", "title_uk", "title_en", "course_id" FROM "core_module";
DROP TABLE "core_module";
ALTER TABLE "new__core_module" RENAME TO "core_module";
CREATE INDEX "core_module_course_id_2aa5c263" ON "core_module" ("course_id");
--
-- Create constraint uniq_module_progress on model moduleprogress
--
CREATE TABLE "new__core_moduleprogress" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "completed_at" datetime NOT NULL, "enrollment_id" bigint NOT NULL REFERENCES "core_enrollment" ("id") DEFERRABLE INITIALLY DEFERRED, "module_id" bigint NOT NULL REFERENCES "core_module" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_module_progress" UNIQUE ("enrollment_id", "module_id"));
INSERT INTO "new__core_moduleprogress" ("id", "completed_at", "enrollment_id", "module_id") SELECT "id", "completed_at", "enrollment_id", "module_id" FROM "core_moduleprogress";
DROP TABLE "core_moduleprogress";
ALTER TABLE "new__core_moduleprogress" RENAME TO "core_moduleprogress";
CREATE INDEX "core_moduleprogress_completed_at_b982518e" ON "core_moduleprogress" ("completed_at");
CREATE INDEX "core_moduleprogress_enrollment_id_a59bb152" ON "core_moduleprogress" ("enrollment_id");
CREATE INDEX "core_moduleprogress_module_id_a907287f" ON "core_moduleprogress" ("module_id");
--
-- Create constraint uniq_course_prereq on model prerequisite
--
CREATE TABLE "new__core_prerequisite" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "min_level" smallint unsigned NOT NULL CHECK ("min_level" >= 0), "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_course_prereq" UNIQUE ("course_id", "skill_id"));
INSERT INTO "new__core_prerequisite" ("id", "min_level", "course_id", "skill_id") SELECT "id", "min_level", "course_id", "skill_id" FROM "core_prerequisite";
DROP TABLE "core_prerequisite";
ALTER TABLE "new__core_prerequisite" RENAME TO "core_prerequisite";
CREATE INDEX "core_prerequisite_course_id_31684edf" ON "core_prerequisite" ("course_id");
CREATE INDEX "core_prerequisite_skill_id_8791abd4" ON "core_prerequisite" ("skill_id");
--
-- Create constraint prereq_min_level_1 on model prerequisite
--
CREATE TABLE "new__core_prerequisite" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "min_level" smallint unsigned NOT NULL CHECK ("min_level" >= 0), "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_course_prereq" UNIQUE ("course_id", "skill_id"), CONSTRAINT "prereq_min_level_1" CHECK ("min_level" >= 1));
INSERT INTO "new__core_prerequisite" ("id", "min_level", "course_id", "skill_id") SELECT "id", "min_level", "course_id", "skill_id" FROM "core_prerequisite";
DROP TABLE "core_prerequisite";
ALTER TABLE "new__core_prerequisite" RENAME TO "core_prerequisite";
CREATE INDEX "core_prerequisite_course_id_31684edf" ON "core_prerequisite" ("course_id");
CREATE INDEX "core_prerequisite_skill_id_8791abd4" ON "core_prerequisite" ("skill_id");
--
-- Create constraint profile_weekly_hours_1_30 on model profile
--
CREATE TABLE "new__core_profile" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "display_name" varchar(60) NOT NULL, "goal" varchar(2) NOT NULL, "weekly_hours" smallint unsigned NOT NULL CHECK ("weekly_hours" >= 0), "preferred_format" varchar(4) NOT NULL, "reminders" bool NOT NULL, "user_id" integer NOT NULL UNIQUE REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "profile_weekly_hours_1_30" CHECK (("weekly_hours" >= 1 AND "weekly_hours" <= 30)));
INSERT INTO "new__core_profile" ("id", "display_name", "goal", "weekly_hours", "preferred_format", "reminders", "user_id") SELECT "id", "display_name", "goal", "weekly_hours", "preferred_format", "reminders", "user_id" FROM "core_profile";
DROP TABLE "core_profile";
ALTER TABLE "new__core_profile" RENAME TO "core_profile";
--
-- Create constraint uniq_recent_view on model recentview
--
CREATE TABLE "new__core_recentview" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "viewed_at" datetime NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_recent_view" UNIQUE ("user_id", "course_id"));
INSERT INTO "new__core_recentview" ("id", "viewed_at", "course_id", "user_id") SELECT "id", "viewed_at", "course_id", "user_id" FROM "core_recentview";
DROP TABLE "core_recentview";
ALTER TABLE "new__core_recentview" RENAME TO "core_recentview";
CREATE INDEX "core_recentview_course_id_1c17ec2b" ON "core_recentview" ("course_id");
CREATE INDEX "core_recentview_user_id_610abd03" ON "core_recentview" ("user_id");
CREATE INDEX "recent_user_idx" ON "core_recentview" ("user_id", "viewed_at" DESC);
--
-- Create constraint uniq_saved_course on model savedcourse
--
CREATE TABLE "new__core_savedcourse" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "created_at" datetime NOT NULL, "course_id" bigint NOT NULL REFERENCES "core_course" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_saved_course" UNIQUE ("user_id", "course_id"));
INSERT INTO "new__core_savedcourse" ("id", "created_at", "course_id", "user_id") SELECT "id", "created_at", "course_id", "user_id" FROM "core_savedcourse";
DROP TABLE "core_savedcourse";
ALTER TABLE "new__core_savedcourse" RENAME TO "core_savedcourse";
CREATE INDEX "core_savedcourse_course_id_cd911f0b" ON "core_savedcourse" ("course_id");
CREATE INDEX "core_savedcourse_user_id_d535cf16" ON "core_savedcourse" ("user_id");
--
-- Create constraint uniq_user_skill on model userskill
--
CREATE TABLE "new__core_userskill" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "current_level" smallint unsigned NOT NULL CHECK ("current_level" >= 0), "desired_level" smallint unsigned NOT NULL CHECK ("desired_level" >= 0), "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_user_skill" UNIQUE ("user_id", "skill_id"));
INSERT INTO "new__core_userskill" ("id", "current_level", "desired_level", "skill_id", "user_id") SELECT "id", "current_level", "desired_level", "skill_id", "user_id" FROM "core_userskill";
DROP TABLE "core_userskill";
ALTER TABLE "new__core_userskill" RENAME TO "core_userskill";
CREATE INDEX "core_userskill_skill_id_b5a74b63" ON "core_userskill" ("skill_id");
CREATE INDEX "core_userskill_user_id_9ea46a66" ON "core_userskill" ("user_id");
CREATE INDEX "userskill_user_idx" ON "core_userskill" ("user_id", "skill_id");
--
-- Create constraint userskill_cur_lte_5 on model userskill
--
CREATE TABLE "new__core_userskill" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "current_level" smallint unsigned NOT NULL CHECK ("current_level" >= 0), "desired_level" smallint unsigned NOT NULL CHECK ("desired_level" >= 0), "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_user_skill" UNIQUE ("user_id", "skill_id"), CONSTRAINT "userskill_cur_lte_5" CHECK ("current_level" <= 5));
INSERT INTO "new__core_userskill" ("id", "current_level", "desired_level", "skill_id", "user_id") SELECT "id", "current_level", "desired_level", "skill_id", "user_id" FROM "core_userskill";
DROP TABLE "core_userskill";
ALTER TABLE "new__core_userskill" RENAME TO "core_userskill";
CREATE INDEX "core_userskill_skill_id_b5a74b63" ON "core_userskill" ("skill_id");
CREATE INDEX "core_userskill_user_id_9ea46a66" ON "core_userskill" ("user_id");
CREATE INDEX "userskill_user_idx" ON "core_userskill" ("user_id", "skill_id");
--
-- Create constraint userskill_want_lte_5 on model userskill
--
CREATE TABLE "new__core_userskill" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "current_level" smallint unsigned NOT NULL CHECK ("current_level" >= 0), "desired_level" smallint unsigned NOT NULL CHECK ("desired_level" >= 0), "skill_id" bigint NOT NULL REFERENCES "core_skill" ("id") DEFERRABLE INITIALLY DEFERRED, "user_id" integer NOT NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED, CONSTRAINT "uniq_user_skill" UNIQUE ("user_id", "skill_id"), CONSTRAINT "userskill_cur_lte_5" CHECK ("current_level" <= 5), CONSTRAINT "userskill_want_lte_5" CHECK ("desired_level" <= 5));
INSERT INTO "new__core_userskill" ("id", "current_level", "desired_level", "skill_id", "user_id") SELECT "id", "current_level", "desired_level", "skill_id", "user_id" FROM "core_userskill";
DROP TABLE "core_userskill";
ALTER TABLE "new__core_userskill" RENAME TO "core_userskill";
CREATE INDEX "core_userskill_skill_id_b5a74b63" ON "core_userskill" ("skill_id");
CREATE INDEX "core_userskill_user_id_9ea46a66" ON "core_userskill" ("user_id");
CREATE INDEX "userskill_user_idx" ON "core_userskill" ("user_id", "skill_id");
--
-- Create index agent_kb_idx on field(s) is_active, -priority of model agentknowledge
--
CREATE INDEX "agent_kb_idx" ON "core_agentknowledge" ("is_active", "priority" DESC);
--
-- Create constraint uniq_agent_knowledge_key on model agentknowledge
--
CREATE TABLE "new__core_agentknowledge" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "key" varchar(50) NOT NULL UNIQUE, "keywords" varchar(200) NOT NULL, "question_uk" varchar(200) NOT NULL, "question_en" varchar(200) NOT NULL, "answer_uk" text NOT NULL, "answer_en" text NOT NULL, "priority" smallint unsigned NOT NULL CHECK ("priority" >= 0), "hits" integer unsigned NOT NULL CHECK ("hits" >= 0), "is_active" bool NOT NULL, CONSTRAINT "uniq_agent_knowledge_key" UNIQUE ("key"));
INSERT INTO "new__core_agentknowledge" ("id", "key", "keywords", "question_uk", "question_en", "answer_uk", "answer_en", "priority", "hits", "is_active") SELECT "id", "key", "keywords", "question_uk", "question_en", "answer_uk", "answer_en", "priority", "hits", "is_active" FROM "core_agentknowledge";
DROP TABLE "core_agentknowledge";
ALTER TABLE "new__core_agentknowledge" RENAME TO "core_agentknowledge";
CREATE INDEX "agent_kb_idx" ON "core_agentknowledge" ("is_active", "priority" DESC);
--
-- Add field user to chatsession
--
ALTER TABLE "core_chatsession" ADD COLUMN "user_id" integer NULL REFERENCES "auth_user" ("id") DEFERRABLE INITIALLY DEFERRED;
--
-- Add field session to chatmessage
--
CREATE TABLE "new__core_chatmessage" ("id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, "role" varchar(5) NOT NULL, "content" text NOT NULL, "source" varchar(16) NOT NULL, "created_at" datetime NOT NULL, "session_id" bigint NOT NULL REFERENCES "core_chatsession" ("id") DEFERRABLE INITIALLY DEFERRED);
INSERT INTO "new__core_chatmessage" ("id", "role", "content", "source", "created_at", "session_id") SELECT "id", "role", "content", "source", "created_at", NULL FROM "core_chatmessage";
DROP TABLE "core_chatmessage";
ALTER TABLE "new__core_chatmessage" RENAME TO "core_chatmessage";
CREATE INDEX "core_chatsession_user_id_1929cfbb" ON "core_chatsession" ("user_id");
CREATE INDEX "core_chatmessage_created_at_d3e617df" ON "core_chatmessage" ("created_at");
CREATE INDEX "core_chatmessage_session_id_e3c386aa" ON "core_chatmessage" ("session_id");
--
-- Create index chatsession_user_idx on field(s) user, -updated_at of model chatsession
--
CREATE INDEX "chatsession_user_idx" ON "core_chatsession" ("user_id", "updated_at" DESC);
--
-- Create index chatmsg_session_idx on field(s) session, created_at of model chatmessage
--
CREATE INDEX "chatmsg_session_idx" ON "core_chatmessage" ("session_id", "created_at");
COMMIT;
