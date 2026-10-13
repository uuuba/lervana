-- Learnova: SQL-скрипт створення таблиць (згенеровано з міграцій Django).
-- СУБД: MySQL 8.0 (InnoDB, utf8mb4). Джерело: python manage.py sqlmigrate core 0001 / core 0002
-- Увага: DDL діалекту MySQL; для SQLite/Postgres він відрізняється.

--
-- Create model Course
--
CREATE TABLE `core_course` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `title_uk` varchar(160) NOT NULL, `title_en` varchar(160) NOT NULL, `description_uk` longtext NOT NULL, `description_en` longtext NOT NULL, `level` smallint UNSIGNED NOT NULL CHECK (`level` >= 0), `duration_hours` smallint UNSIGNED NOT NULL CHECK (`duration_hours` >= 0), `format` varchar(4) NOT NULL, `is_published` bool NOT NULL);
--
-- Create model Interest
--
CREATE TABLE `core_interest` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `key` varchar(50) NOT NULL UNIQUE, `name_uk` varchar(80) NOT NULL, `name_en` varchar(80) NOT NULL);
--
-- Create model Skill
--
CREATE TABLE `core_skill` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `key` varchar(50) NOT NULL UNIQUE, `name_uk` varchar(80) NOT NULL, `name_en` varchar(80) NOT NULL);
--
-- Create model Enrollment
--
CREATE TABLE `core_enrollment` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `started_at` datetime(6) NOT NULL, `course_id` bigint NOT NULL, `user_id` integer NOT NULL);
--
-- Add field category to course
--
ALTER TABLE `core_course` ADD COLUMN `category_id` bigint NOT NULL , ADD CONSTRAINT `core_course_category_id_6eee1bdf_fk_core_interest_id` FOREIGN KEY (`category_id`) REFERENCES `core_interest`(`id`);
--
-- Add field interests to course
--
CREATE TABLE `core_course_interests` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `course_id` bigint NOT NULL, `interest_id` bigint NOT NULL);
--
-- Create model Module
--
CREATE TABLE `core_module` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `order` smallint UNSIGNED NOT NULL CHECK (`order` >= 0), `title_uk` varchar(160) NOT NULL, `title_en` varchar(160) NOT NULL, `course_id` bigint NOT NULL);
--
-- Create model Notification
--
CREATE TABLE `core_notification` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `code` varchar(20) NOT NULL, `is_read` bool NOT NULL, `created_at` datetime(6) NOT NULL, `user_id` integer NOT NULL);
--
-- Create model Profile
--
CREATE TABLE `core_profile` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `display_name` varchar(60) NOT NULL, `goal` varchar(2) NOT NULL, `weekly_hours` smallint UNSIGNED NOT NULL CHECK (`weekly_hours` >= 0), `preferred_format` varchar(4) NOT NULL, `reminders` bool NOT NULL, `user_id` integer NOT NULL UNIQUE);
CREATE TABLE `core_profile_interests` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `profile_id` bigint NOT NULL, `interest_id` bigint NOT NULL);
--
-- Create model CourseSkill
--
CREATE TABLE `core_courseskill` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `order` smallint UNSIGNED NOT NULL CHECK (`order` >= 0), `course_id` bigint NOT NULL, `skill_id` bigint NOT NULL);
--
-- Add field skills to course
--
-- (no-op)
--
-- Create model ModuleProgress
--
CREATE TABLE `core_moduleprogress` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `completed_at` datetime(6) NOT NULL, `enrollment_id` bigint NOT NULL, `module_id` bigint NOT NULL);
--
-- Create model RecentView
--
CREATE TABLE `core_recentview` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `viewed_at` datetime(6) NOT NULL, `course_id` bigint NOT NULL, `user_id` integer NOT NULL);
--
-- Create model SavedCourse
--
CREATE TABLE `core_savedcourse` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `created_at` datetime(6) NOT NULL, `course_id` bigint NOT NULL, `user_id` integer NOT NULL);
--
-- Create model Prerequisite
--
CREATE TABLE `core_prerequisite` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `min_level` smallint UNSIGNED NOT NULL CHECK (`min_level` >= 0), `course_id` bigint NOT NULL, `skill_id` bigint NOT NULL);
--
-- Create model UserSkill
--
CREATE TABLE `core_userskill` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `current_level` smallint UNSIGNED NOT NULL CHECK (`current_level` >= 0), `desired_level` smallint UNSIGNED NOT NULL CHECK (`desired_level` >= 0), `skill_id` bigint NOT NULL, `user_id` integer NOT NULL);
ALTER TABLE `core_enrollment` ADD CONSTRAINT `core_enrollment_user_id_course_id_0fb0d47c_uniq` UNIQUE (`user_id`, `course_id`);
ALTER TABLE `core_enrollment` ADD CONSTRAINT `core_enrollment_course_id_fe1f9f12_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`);
ALTER TABLE `core_enrollment` ADD CONSTRAINT `core_enrollment_user_id_676c05fa_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);
ALTER TABLE `core_course_interests` ADD CONSTRAINT `core_course_interests_course_id_interest_id_e6b15044_uniq` UNIQUE (`course_id`, `interest_id`);
ALTER TABLE `core_course_interests` ADD CONSTRAINT `core_course_interests_course_id_3ad05d74_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`);
ALTER TABLE `core_course_interests` ADD CONSTRAINT `core_course_interests_interest_id_966cfbb0_fk_core_interest_id` FOREIGN KEY (`interest_id`) REFERENCES `core_interest` (`id`);
ALTER TABLE `core_module` ADD CONSTRAINT `core_module_course_id_2aa5c263_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`);
ALTER TABLE `core_notification` ADD CONSTRAINT `core_notification_user_id_6e341aac_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);
ALTER TABLE `core_profile` ADD CONSTRAINT `core_profile_user_id_bf8ada58_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);
ALTER TABLE `core_profile_interests` ADD CONSTRAINT `core_profile_interests_profile_id_interest_id_121c02f1_uniq` UNIQUE (`profile_id`, `interest_id`);
ALTER TABLE `core_profile_interests` ADD CONSTRAINT `core_profile_interests_profile_id_049b9d41_fk_core_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `core_profile` (`id`);
ALTER TABLE `core_profile_interests` ADD CONSTRAINT `core_profile_interests_interest_id_9944bc46_fk_core_interest_id` FOREIGN KEY (`interest_id`) REFERENCES `core_interest` (`id`);
ALTER TABLE `core_courseskill` ADD CONSTRAINT `core_courseskill_course_id_skill_id_405f690f_uniq` UNIQUE (`course_id`, `skill_id`);
ALTER TABLE `core_courseskill` ADD CONSTRAINT `core_courseskill_course_id_5c9ae85a_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`);
ALTER TABLE `core_courseskill` ADD CONSTRAINT `core_courseskill_skill_id_d2bf5dfb_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`);
ALTER TABLE `core_moduleprogress` ADD CONSTRAINT `core_moduleprogress_enrollment_id_module_id_3546586a_uniq` UNIQUE (`enrollment_id`, `module_id`);
ALTER TABLE `core_moduleprogress` ADD CONSTRAINT `core_moduleprogress_enrollment_id_a59bb152_fk_core_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `core_enrollment` (`id`);
ALTER TABLE `core_moduleprogress` ADD CONSTRAINT `core_moduleprogress_module_id_a907287f_fk_core_module_id` FOREIGN KEY (`module_id`) REFERENCES `core_module` (`id`);
ALTER TABLE `core_recentview` ADD CONSTRAINT `core_recentview_user_id_course_id_5c785a04_uniq` UNIQUE (`user_id`, `course_id`);
ALTER TABLE `core_recentview` ADD CONSTRAINT `core_recentview_course_id_1c17ec2b_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`);
ALTER TABLE `core_recentview` ADD CONSTRAINT `core_recentview_user_id_610abd03_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);
ALTER TABLE `core_savedcourse` ADD CONSTRAINT `core_savedcourse_user_id_course_id_5ec9a98c_uniq` UNIQUE (`user_id`, `course_id`);
ALTER TABLE `core_savedcourse` ADD CONSTRAINT `core_savedcourse_course_id_cd911f0b_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`);
ALTER TABLE `core_savedcourse` ADD CONSTRAINT `core_savedcourse_user_id_d535cf16_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);
ALTER TABLE `core_prerequisite` ADD CONSTRAINT `core_prerequisite_course_id_skill_id_cbb2ed7a_uniq` UNIQUE (`course_id`, `skill_id`);
ALTER TABLE `core_prerequisite` ADD CONSTRAINT `core_prerequisite_course_id_31684edf_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`);
ALTER TABLE `core_prerequisite` ADD CONSTRAINT `core_prerequisite_skill_id_8791abd4_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`);
ALTER TABLE `core_userskill` ADD CONSTRAINT `core_userskill_user_id_skill_id_8fe1cd4b_uniq` UNIQUE (`user_id`, `skill_id`);
ALTER TABLE `core_userskill` ADD CONSTRAINT `core_userskill_skill_id_b5a74b63_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`);
ALTER TABLE `core_userskill` ADD CONSTRAINT `core_userskill_user_id_9ea46a66_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Create model AgentKnowledge
--
CREATE TABLE `core_agentknowledge` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `key` varchar(50) NOT NULL UNIQUE, `keywords` varchar(200) NOT NULL, `question_uk` varchar(200) NOT NULL, `question_en` varchar(200) NOT NULL, `answer_uk` longtext NOT NULL, `answer_en` longtext NOT NULL, `priority` smallint UNSIGNED NOT NULL CHECK (`priority` >= 0), `hits` integer UNSIGNED NOT NULL CHECK (`hits` >= 0), `is_active` bool NOT NULL);
--
-- Create model ChatMessage
--
CREATE TABLE `core_chatmessage` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `role` varchar(5) NOT NULL, `content` longtext NOT NULL, `source` varchar(16) NOT NULL, `created_at` datetime(6) NOT NULL);
--
-- Create model ChatSession
--
CREATE TABLE `core_chatsession` (`id` bigint AUTO_INCREMENT NOT NULL PRIMARY KEY, `session_key` varchar(40) NOT NULL, `created_at` datetime(6) NOT NULL, `updated_at` datetime(6) NOT NULL);
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
ALTER TABLE `core_courseskill` DROP INDEX `uniq_course_skill`;
--
-- Alter unique_together for enrollment (0 constraint(s))
--
ALTER TABLE `core_enrollment` DROP INDEX `uniq_enrollment`;
--
-- Alter unique_together for moduleprogress (0 constraint(s))
--
ALTER TABLE `core_moduleprogress` DROP INDEX `uniq_module_progress`;
--
-- Alter unique_together for prerequisite (0 constraint(s))
--
ALTER TABLE `core_prerequisite` DROP INDEX `uniq_course_prereq`;
--
-- Alter unique_together for recentview (0 constraint(s))
--
ALTER TABLE `core_recentview` DROP INDEX `uniq_recent_view`;
--
-- Alter unique_together for savedcourse (0 constraint(s))
--
ALTER TABLE `core_savedcourse` DROP INDEX `uniq_saved_course`;
--
-- Alter unique_together for userskill (0 constraint(s))
--
ALTER TABLE `core_userskill` DROP INDEX `uniq_user_skill`;
--
-- Add field cover_key to course
--
ALTER TABLE `core_course` ADD COLUMN `cover_key` varchar(32) DEFAULT '' NOT NULL;
ALTER TABLE `core_course` ALTER COLUMN `cover_key` DROP DEFAULT;
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
CREATE INDEX `core_moduleprogress_completed_at_b982518e` ON `core_moduleprogress` (`completed_at`);
--
-- Alter field module on moduleprogress
--
-- (no-op)
--
-- Alter field code on notification
--
CREATE INDEX `core_notification_code_fe90977e` ON `core_notification` (`code`);
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
CREATE INDEX `course_pub_lvl_idx` ON `core_course` (`is_published`, `level`);
--
-- Create index course_cat_fmt_idx on field(s) category, format of model course
--
CREATE INDEX `course_cat_fmt_idx` ON `core_course` (`category_id`, `format`);
--
-- Create index courseskill_skill_idx on field(s) skill, order of model courseskill
--
CREATE INDEX `courseskill_skill_idx` ON `core_courseskill` (`skill_id`, `order`);
--
-- Create index enroll_user_idx on field(s) user, started_at of model enrollment
--
CREATE INDEX `enroll_user_idx` ON `core_enrollment` (`user_id`, `started_at`);
--
-- Create index notif_user_read_idx on field(s) user, is_read of model notification
--
CREATE INDEX `notif_user_read_idx` ON `core_notification` (`user_id`, `is_read`);
--
-- Create index recent_user_idx on field(s) user, -viewed_at of model recentview
--
CREATE INDEX `recent_user_idx` ON `core_recentview` (`user_id`, `viewed_at` DESC);
--
-- Create index userskill_user_idx on field(s) user, skill of model userskill
--
CREATE INDEX `userskill_user_idx` ON `core_userskill` (`user_id`, `skill_id`);
--
-- Create constraint course_level_1_3 on model course
--
ALTER TABLE `core_course` ADD CONSTRAINT `course_level_1_3` CHECK (`level` IN (1, 2, 3));
--
-- Create constraint course_hours_positive on model course
--
ALTER TABLE `core_course` ADD CONSTRAINT `course_hours_positive` CHECK (`duration_hours` > 0);
--
-- Create constraint uniq_course_skill on model courseskill
--
ALTER TABLE `core_courseskill` ADD CONSTRAINT `uniq_course_skill` UNIQUE (`course_id`, `skill_id`);
--
-- Create constraint uniq_enrollment on model enrollment
--
ALTER TABLE `core_enrollment` ADD CONSTRAINT `uniq_enrollment` UNIQUE (`user_id`, `course_id`);
--
-- Create constraint uniq_course_module_order on model module
--
ALTER TABLE `core_module` ADD CONSTRAINT `uniq_course_module_order` UNIQUE (`course_id`, `order`);
--
-- Create constraint uniq_module_progress on model moduleprogress
--
ALTER TABLE `core_moduleprogress` ADD CONSTRAINT `uniq_module_progress` UNIQUE (`enrollment_id`, `module_id`);
--
-- Create constraint uniq_course_prereq on model prerequisite
--
ALTER TABLE `core_prerequisite` ADD CONSTRAINT `uniq_course_prereq` UNIQUE (`course_id`, `skill_id`);
--
-- Create constraint prereq_min_level_1 on model prerequisite
--
ALTER TABLE `core_prerequisite` ADD CONSTRAINT `prereq_min_level_1` CHECK (`min_level` >= 1);
--
-- Create constraint profile_weekly_hours_1_30 on model profile
--
ALTER TABLE `core_profile` ADD CONSTRAINT `profile_weekly_hours_1_30` CHECK ((`weekly_hours` >= 1 AND `weekly_hours` <= 30));
--
-- Create constraint uniq_recent_view on model recentview
--
ALTER TABLE `core_recentview` ADD CONSTRAINT `uniq_recent_view` UNIQUE (`user_id`, `course_id`);
--
-- Create constraint uniq_saved_course on model savedcourse
--
ALTER TABLE `core_savedcourse` ADD CONSTRAINT `uniq_saved_course` UNIQUE (`user_id`, `course_id`);
--
-- Create constraint uniq_user_skill on model userskill
--
ALTER TABLE `core_userskill` ADD CONSTRAINT `uniq_user_skill` UNIQUE (`user_id`, `skill_id`);
--
-- Create constraint userskill_cur_lte_5 on model userskill
--
ALTER TABLE `core_userskill` ADD CONSTRAINT `userskill_cur_lte_5` CHECK (`current_level` <= 5);
--
-- Create constraint userskill_want_lte_5 on model userskill
--
ALTER TABLE `core_userskill` ADD CONSTRAINT `userskill_want_lte_5` CHECK (`desired_level` <= 5);
--
-- Create index agent_kb_idx on field(s) is_active, -priority of model agentknowledge
--
CREATE INDEX `agent_kb_idx` ON `core_agentknowledge` (`is_active`, `priority` DESC);
--
-- Create constraint uniq_agent_knowledge_key on model agentknowledge
--
ALTER TABLE `core_agentknowledge` ADD CONSTRAINT `uniq_agent_knowledge_key` UNIQUE (`key`);
--
-- Add field user to chatsession
--
ALTER TABLE `core_chatsession` ADD COLUMN `user_id` integer NULL , ADD CONSTRAINT `core_chatsession_user_id_1929cfbb_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user`(`id`);
--
-- Add field session to chatmessage
--
ALTER TABLE `core_chatmessage` ADD COLUMN `session_id` bigint NOT NULL , ADD CONSTRAINT `core_chatmessage_session_id_e3c386aa_fk_core_chatsession_id` FOREIGN KEY (`session_id`) REFERENCES `core_chatsession`(`id`);
--
-- Create index chatsession_user_idx on field(s) user, -updated_at of model chatsession
--
CREATE INDEX `chatsession_user_idx` ON `core_chatsession` (`user_id`, `updated_at` DESC);
--
-- Create index chatmsg_session_idx on field(s) session, created_at of model chatmessage
--
CREATE INDEX `chatmsg_session_idx` ON `core_chatmessage` (`session_id`, `created_at`);
CREATE INDEX `core_chatmessage_created_at_d3e617df` ON `core_chatmessage` (`created_at`);
CREATE INDEX `core_chatsession_session_key_bf5fe52f` ON `core_chatsession` (`session_key`);
CREATE INDEX `core_course_cover_key_321bde95` ON `core_course` (`cover_key`);
