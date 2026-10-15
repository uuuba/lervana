-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: learnova
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session'),(25,'Can add курс',7,'add_course'),(26,'Can change курс',7,'change_course'),(27,'Can delete курс',7,'delete_course'),(28,'Can view курс',7,'view_course'),(29,'Can add інтерес',8,'add_interest'),(30,'Can change інтерес',8,'change_interest'),(31,'Can delete інтерес',8,'delete_interest'),(32,'Can view інтерес',8,'view_interest'),(33,'Can add навичка',9,'add_skill'),(34,'Can change навичка',9,'change_skill'),(35,'Can delete навичка',9,'delete_skill'),(36,'Can view навичка',9,'view_skill'),(37,'Can add запис на курс',10,'add_enrollment'),(38,'Can change запис на курс',10,'change_enrollment'),(39,'Can delete запис на курс',10,'delete_enrollment'),(40,'Can view запис на курс',10,'view_enrollment'),(41,'Can add модуль',11,'add_module'),(42,'Can change модуль',11,'change_module'),(43,'Can delete модуль',11,'delete_module'),(44,'Can view модуль',11,'view_module'),(45,'Can add сповіщення',12,'add_notification'),(46,'Can change сповіщення',12,'change_notification'),(47,'Can delete сповіщення',12,'delete_notification'),(48,'Can view сповіщення',12,'view_notification'),(49,'Can add профіль',13,'add_profile'),(50,'Can change профіль',13,'change_profile'),(51,'Can delete профіль',13,'delete_profile'),(52,'Can view профіль',13,'view_profile'),(53,'Can add навичка курсу',14,'add_courseskill'),(54,'Can change навичка курсу',14,'change_courseskill'),(55,'Can delete навичка курсу',14,'delete_courseskill'),(56,'Can view навичка курсу',14,'view_courseskill'),(57,'Can add виконаний модуль',15,'add_moduleprogress'),(58,'Can change виконаний модуль',15,'change_moduleprogress'),(59,'Can delete виконаний модуль',15,'delete_moduleprogress'),(60,'Can view виконаний модуль',15,'view_moduleprogress'),(61,'Can add перегляд',16,'add_recentview'),(62,'Can change перегляд',16,'change_recentview'),(63,'Can delete перегляд',16,'delete_recentview'),(64,'Can view перегляд',16,'view_recentview'),(65,'Can add збережений курс',17,'add_savedcourse'),(66,'Can change збережений курс',17,'change_savedcourse'),(67,'Can delete збережений курс',17,'delete_savedcourse'),(68,'Can view збережений курс',17,'view_savedcourse'),(69,'Can add передумова',18,'add_prerequisite'),(70,'Can change передумова',18,'change_prerequisite'),(71,'Can delete передумова',18,'delete_prerequisite'),(72,'Can view передумова',18,'view_prerequisite'),(73,'Can add рівень навички',19,'add_userskill'),(74,'Can change рівень навички',19,'change_userskill'),(75,'Can delete рівень навички',19,'delete_userskill'),(76,'Can view рівень навички',19,'view_userskill'),(77,'Can add знання агента',20,'add_agentknowledge'),(78,'Can change знання агента',20,'change_agentknowledge'),(79,'Can delete знання агента',20,'delete_agentknowledge'),(80,'Can view знання агента',20,'view_agentknowledge'),(81,'Can add повідомлення агента',21,'add_chatmessage'),(82,'Can change повідомлення агента',21,'change_chatmessage'),(83,'Can delete повідомлення агента',21,'delete_chatmessage'),(84,'Can view повідомлення агента',21,'view_chatmessage'),(85,'Can add діалог з агентом',22,'add_chatsession'),(86,'Can change діалог з агентом',22,'change_chatsession'),(87,'Can delete діалог з агентом',22,'delete_chatsession'),(88,'Can view діалог з агентом',22,'view_chatsession');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$1000000$pssSyvN3xUu4G7khXukpHQ$TUi88khZ31WEx3M0WJR1R5gJiKxUMo5g3yo5rISwKmg=','2026-10-14 06:38:34.392476',0,'demo','','','',0,1,'2026-10-13 07:02:02.162783'),(2,'pbkdf2_sha256$1000000$e94kbWYEIAfgtyjaQTOKym$aXuziFrYbxbDE8zfFttSAhDU1y3pd14/4pfZ78My4PA=','2026-10-13 09:37:31.204917',0,'bd','','','',0,1,'2026-10-13 09:37:30.391111');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_agentknowledge`
--

DROP TABLE IF EXISTS `core_agentknowledge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_agentknowledge` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keywords` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_uk` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_en` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer_uk` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer_en` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` smallint unsigned NOT NULL,
  `hits` int unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`),
  UNIQUE KEY `uniq_agent_knowledge_key` (`key`),
  KEY `agent_kb_idx` (`is_active`,`priority` DESC),
  CONSTRAINT `core_agentknowledge_chk_1` CHECK ((`priority` >= 0)),
  CONSTRAINT `core_agentknowledge_chk_2` CHECK ((`hits` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_agentknowledge`
--

LOCK TABLES `core_agentknowledge` WRITE;
/*!40000 ALTER TABLE `core_agentknowledge` DISABLE KEYS */;
INSERT INTO `core_agentknowledge` VALUES (1,'who','хто ти хто ви що ти бот агент who you assistant','Хто ти такий?','Who are you?','Я — «ШІ-агент» Learnova: пародія на AI-асистента. Нейромережі немає — є база знань (таблиця agentknowledge) і запити до твоїх таблиць.','I am the Learnova \"AI agent\": an AI-assistant parody. No neural network — just a knowledge base (the agentknowledge table) and queries to your tables.',30,2,1),(2,'ai','ші ai нейромережа штучний інтелект chatgpt гпт справжній штучний','Ти справжній ШІ?','Are you a real AI?','Ні 😄 Я шукаю ключові слова у запитанні, а потім роблю SQL-запити до таблиць Learnova. Цифри реальні, бо з бази даних.','No 😄 I match keywords in your question and then run SQL queries against Learnova tables. The numbers are real — they come from the database.',30,2,1),(3,'how','як це працює рекомендації формула алгоритм збіг чому рекомендують how it works','Як працюють рекомендації?','How do recommendations work?','Оцінка збігу (0–100) = інтереси 40 + прогалини в навичках 30 + рівень 20 + формат 10. Прозора формула, а не «чорна скринька»; завершені курси прибираються.','Match score (0–100) = interests 40 + skill gaps 30 + level 20 + format 10. A transparent formula, not a black box; completed courses are removed.',20,0,1),(4,'plan','як навчатися план розклад скільки годин на тиждень як почати where to start','З чого почати навчання?','Where should I start?','Заповни профіль (інтереси та рівні) → відкрий «Рекомендації» → натисни «Почати» на курсі → відмічай модулі в «Плані». Прогрес рахують таблиці enrollment і moduleprogress.','Fill in your profile (interests and levels) → open “Recommendations” → press “Start” on a course → tick modules in “Plan”. Progress is counted by the enrollment and moduleprogress tables.',15,0,1),(5,'progress','як подивитись прогрес статистика досягнення серія де мій прогрес','Де подивитись прогрес?','Where is my progress?','Сторінка «Прогрес»: загальний відсоток, активність за тиждень і по кожному курсу. Дані — з таблиць moduleprogress та enrollment.','The “Progress” page: overall percentage, weekly activity and per-course data. Everything comes from the moduleprogress and enrollment tables.',15,0,1),(6,'cert','сертифікат сертифікати диплом підтвердження certificate','Чи є сертифікат?','Is there a certificate?','У демо-сертифікатів немає. Натомість є реальна статистика: години навчання, серія днів і рівні навичок — усе з твоїх таблиць.','There are no certificates in the demo. Instead you get real statistics: learning hours, day streak and skill levels — all from your tables.',10,0,1),(7,'price','ціна скільки коштує вартість безкоштовно підписка price free','Скільки коштує навчання?','How much does it cost?','Нічого: Learnova — навчальний прототип, у таблиці course навіть немає поля «ціна».','Nothing: Learnova is a study prototype — the course table does not even have a price column.',10,0,1),(8,'support','підтримка контакти звʼязатись написати скарга support contact','Як звʼязатись з підтримкою?','How do I contact support?','Це демо-проєкт: налаштування акаунта — на сторінці «Налаштування», а дані можна скинути там само (кнопка «Скинути демо-дані»).','This is a demo: account settings live on the “Settings” page, where you can also reset the demo data.',10,0,1);
/*!40000 ALTER TABLE `core_agentknowledge` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_chatmessage`
--

DROP TABLE IF EXISTS `core_chatmessage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_chatmessage` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `session_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `chatmsg_session_idx` (`session_id`,`created_at`),
  KEY `core_chatmessage_created_at_d3e617df` (`created_at`),
  CONSTRAINT `core_chatmessage_session_id_e3c386aa_fk_core_chatsession_id` FOREIGN KEY (`session_id`) REFERENCES `core_chatsession` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_chatmessage`
--

LOCK TABLES `core_chatmessage` WRITE;
/*!40000 ALTER TABLE `core_chatmessage` DISABLE KEYS */;
INSERT INTO `core_chatmessage` VALUES (1,'user','??????? ?????? ? ?????????','db','2026-10-13 07:15:54.130904',1),(2,'agent','Не знаю відповіді: такого запитання немає в моїй базі знань. Спробуй: «Хто ти такий?», «Ти справжній ШІ?», «Як працюють рекомендації?».','fallback','2026-10-13 07:15:54.132302',1),(3,'user','?????? ????? ??? Python','db','2026-10-13 07:15:54.224601',1),(4,'agent','«Python з нуля»: Початковий рівень, 18 годин, формат — Відео. Навички: Python. Модулів у програмі: 3. Ти вже завершив цей курс ✓','db','2026-10-13 07:15:54.225612',1),(5,'user','??? ?? ??????','db','2026-10-13 07:15:54.305577',1),(6,'agent','Не знаю відповіді: такого запитання немає в моїй базі знань. Спробуй: «Хто ти такий?», «Ти справжній ШІ?», «Як працюють рекомендації?».','fallback','2026-10-13 07:15:54.306530',1),(7,'user','????? ????? ????? ??? ?????','db','2026-10-13 07:15:54.408563',1),(8,'agent','Не знаю відповіді: такого запитання немає в моїй базі знань. Спробуй: «Хто ти такий?», «Ти справжній ШІ?», «Як працюють рекомендації?».','fallback','2026-10-13 07:15:54.409450',1),(9,'user','2+2','db','2026-10-13 09:38:54.995098',2),(10,'agent','Не знаю відповіді: такого запитання немає в моїй базі знань. Спробуй: «Хто ти такий?», «Ти справжній ШІ?», «Як працюють рекомендації?».','fallback','2026-10-13 09:38:54.996346',2),(11,'user','Ти справжній ШІ?','db','2026-10-13 09:39:00.824862',2),(12,'agent','Ні 😄 Я шукаю ключові слова у запитанні, а потім роблю SQL-запити до таблиць Learnova. Цифри реальні, бо з бази даних.','kb','2026-10-13 09:39:00.826016',2),(13,'user','Як працюють рекомендації?','db','2026-10-13 09:39:06.211324',2),(14,'agent','Є 8 кандидатів. Топ-3: «Технічна англійська для IT» — 87%, «Адаптивна верстка» — 67%, «Основи UI/UX» — 57%. Пояснення для першого: Збіг з інтересами: Англійська для IT. Закриває прогалини: Англійська. Курс підходить за рівнем.','db','2026-10-13 09:39:06.212372',2),(15,'user','Як працюють рекомендації?','db','2026-10-13 09:39:09.361594',2),(16,'agent','Є 8 кандидатів. Топ-3: «Технічна англійська для IT» — 87%, «Адаптивна верстка» — 67%, «Основи UI/UX» — 57%. Пояснення для першого: Збіг з інтересами: Англійська для IT. Закриває прогалини: Англійська. Курс підходить за рівнем.','db','2026-10-13 09:39:09.362599',2),(17,'user','З чого почати навчання?','db','2026-10-13 09:39:10.773672',2),(18,'agent','«Машинне навчання: вступ»: Просунутий рівень, 45 годин, формат — Відео. Навички: Аналіз даних. Модулів у програмі: 3. Курс ще не додано до плану Передумови: Python ≥ 3.','db','2026-10-13 09:39:10.775126',2),(19,'user','Ти справжній ШІ?','db','2026-10-13 09:39:12.407731',2),(20,'agent','Ні 😄 Я шукаю ключові слова у запитанні, а потім роблю SQL-запити до таблиць Learnova. Цифри реальні, бо з бази даних.','kb','2026-10-13 09:39:12.409032',2),(21,'user','Хто ти такий?','db','2026-10-13 09:39:13.298542',2),(22,'agent','Я — «ШІ-агент» Learnova: пародія на AI-асистента. Нейромережі немає — є база знань (таблиця agentknowledge) і запити до твоїх таблиць.','kb','2026-10-13 09:39:13.301038',2);
/*!40000 ALTER TABLE `core_chatmessage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_chatsession`
--

DROP TABLE IF EXISTS `core_chatsession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_chatsession` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `session_key` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `chatsession_user_idx` (`user_id`,`updated_at` DESC),
  KEY `core_chatsession_session_key_bf5fe52f` (`session_key`),
  CONSTRAINT `core_chatsession_user_id_1929cfbb_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_chatsession`
--

LOCK TABLES `core_chatsession` WRITE;
/*!40000 ALTER TABLE `core_chatsession` DISABLE KEYS */;
INSERT INTO `core_chatsession` VALUES (1,'','2026-10-13 07:13:39.147585','2026-10-13 07:15:54.410043',1),(2,'','2026-10-13 09:38:46.111497','2026-10-13 09:39:13.302082',2);
/*!40000 ALTER TABLE `core_chatsession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_course`
--

DROP TABLE IF EXISTS `core_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_course` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title_uk` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_en` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_uk` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_en` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` smallint unsigned NOT NULL,
  `duration_hours` smallint unsigned NOT NULL,
  `format` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_published` tinyint(1) NOT NULL,
  `category_id` bigint NOT NULL,
  `cover_key` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `course_pub_lvl_idx` (`is_published`,`level`),
  KEY `course_cat_fmt_idx` (`category_id`,`format`),
  KEY `core_course_cover_key_321bde95` (`cover_key`),
  CONSTRAINT `core_course_category_id_6eee1bdf_fk_core_interest_id` FOREIGN KEY (`category_id`) REFERENCES `core_interest` (`id`),
  CONSTRAINT `core_course_chk_1` CHECK ((`level` >= 0)),
  CONSTRAINT `core_course_chk_2` CHECK ((`duration_hours` >= 0)),
  CONSTRAINT `course_hours_positive` CHECK ((`duration_hours` > 0)),
  CONSTRAINT `course_level_1_3` CHECK ((`level` in (1,2,3)))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_course`
--

LOCK TABLES `core_course` WRITE;
/*!40000 ALTER TABLE `core_course` DISABLE KEYS */;
INSERT INTO `core_course` VALUES (1,'Python з нуля','Python from Scratch','Синтаксис, типи даних, функції та файли.','Syntax, data types, functions and files.',1,18,'vid',1,1,'python'),(2,'Django: веб-застосунки','Django Web Apps','Моделі, шаблони та адмін-панель у Django.','Models, templates and the admin panel in Django.',2,30,'prac',1,1,'web'),(3,'SQL і проєктування БД','SQL & Database Design','SQL-запити, нормалізація та ERD.','SQL queries, normalization and ERDs.',2,22,'prac',1,5,'db'),(4,'Основи Data Science','Data Science Basics','Pandas, візуалізація та базова статистика.','Pandas, visualization and basic statistics.',2,35,'vid',1,3,'data'),(5,'Машинне навчання: вступ','Intro to Machine Learning','Класифікація, регресія та оцінка моделей.','Classification, regression and model evaluation.',3,45,'vid',1,4,'ai'),(6,'Адаптивна верстка','Responsive Web Design','HTML, CSS, Flexbox та Grid.','HTML, CSS, Flexbox and Grid.',1,16,'prac',1,2,'web'),(7,'Основи UI/UX','UI/UX Fundamentals','Дослідження користувачів і прототипування.','User research and prototyping.',1,14,'txt',1,6,'ux'),(8,'Технічна англійська для IT','Technical English for IT','Лексика, документація та листування.','Vocabulary, documentation and email.',1,12,'txt',1,7,'eng');
/*!40000 ALTER TABLE `core_course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_course_interests`
--

DROP TABLE IF EXISTS `core_course_interests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_course_interests` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_id` bigint NOT NULL,
  `interest_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `core_course_interests_course_id_interest_id_e6b15044_uniq` (`course_id`,`interest_id`),
  KEY `core_course_interests_interest_id_966cfbb0_fk_core_interest_id` (`interest_id`),
  CONSTRAINT `core_course_interests_course_id_3ad05d74_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`),
  CONSTRAINT `core_course_interests_interest_id_966cfbb0_fk_core_interest_id` FOREIGN KEY (`interest_id`) REFERENCES `core_interest` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_course_interests`
--

LOCK TABLES `core_course_interests` WRITE;
/*!40000 ALTER TABLE `core_course_interests` DISABLE KEYS */;
INSERT INTO `core_course_interests` VALUES (1,1,1),(2,2,1),(3,2,2),(4,2,5),(5,3,5),(6,4,1),(7,4,3),(8,5,3),(9,5,4),(10,6,2),(11,6,6),(12,7,2),(13,7,6),(14,8,7);
/*!40000 ALTER TABLE `core_course_interests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_courseskill`
--

DROP TABLE IF EXISTS `core_courseskill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_courseskill` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` smallint unsigned NOT NULL,
  `course_id` bigint NOT NULL,
  `skill_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_course_skill` (`course_id`,`skill_id`),
  KEY `core_courseskill_course_id_5c9ae85a` (`course_id`),
  KEY `courseskill_skill_idx` (`skill_id`,`order`),
  CONSTRAINT `core_courseskill_course_id_5c9ae85a_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`),
  CONSTRAINT `core_courseskill_skill_id_d2bf5dfb_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`),
  CONSTRAINT `core_courseskill_chk_1` CHECK ((`order` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_courseskill`
--

LOCK TABLES `core_courseskill` WRITE;
/*!40000 ALTER TABLE `core_courseskill` DISABLE KEYS */;
INSERT INTO `core_courseskill` VALUES (11,0,1,1),(12,0,2,2),(13,1,2,1),(14,0,3,3),(15,0,4,4),(16,1,4,1),(17,0,5,4),(18,0,6,2),(19,0,7,2),(20,0,8,5);
/*!40000 ALTER TABLE `core_courseskill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_enrollment`
--

DROP TABLE IF EXISTS `core_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_enrollment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `started_at` datetime(6) NOT NULL,
  `course_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_enrollment` (`user_id`,`course_id`),
  KEY `core_enrollment_course_id_fe1f9f12_fk_core_course_id` (`course_id`),
  KEY `core_enrollment_user_id_676c05fa` (`user_id`),
  KEY `enroll_user_idx` (`user_id`,`started_at`),
  CONSTRAINT `core_enrollment_course_id_fe1f9f12_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`),
  CONSTRAINT `core_enrollment_user_id_676c05fa_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_enrollment`
--

LOCK TABLES `core_enrollment` WRITE;
/*!40000 ALTER TABLE `core_enrollment` DISABLE KEYS */;
INSERT INTO `core_enrollment` VALUES (1,'2026-10-13 07:02:03.236226',1,1),(2,'2026-10-13 07:02:03.256215',2,1);
/*!40000 ALTER TABLE `core_enrollment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_interest`
--

DROP TABLE IF EXISTS `core_interest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_interest` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_uk` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_interest`
--

LOCK TABLES `core_interest` WRITE;
/*!40000 ALTER TABLE `core_interest` DISABLE KEYS */;
INSERT INTO `core_interest` VALUES (1,'python','Python','Python'),(2,'web','Веб-розробка','Web development'),(3,'data','Data Science','Data Science'),(4,'ai','AI/ML','AI/ML'),(5,'db','Бази даних','Databases'),(6,'ux','UI/UX','UI/UX'),(7,'eng','Англійська для IT','English for IT');
/*!40000 ALTER TABLE `core_interest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_module`
--

DROP TABLE IF EXISTS `core_module`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_module` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` smallint unsigned NOT NULL,
  `title_uk` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_en` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_course_module_order` (`course_id`,`order`),
  CONSTRAINT `core_module_course_id_2aa5c263_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`),
  CONSTRAINT `core_module_chk_1` CHECK ((`order` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_module`
--

LOCK TABLES `core_module` WRITE;
/*!40000 ALTER TABLE `core_module` DISABLE KEYS */;
INSERT INTO `core_module` VALUES (1,1,'Основи: Python','Fundamentals: Python',1),(2,2,'Практика: Python','Practice: Python',1),(3,3,'Міні-проєкт','Mini project',1),(4,1,'Основи: Веб','Fundamentals: Web',2),(5,2,'Практика: Python','Practice: Python',2),(6,3,'Міні-проєкт','Mini project',2),(7,1,'Основи: Бази даних','Fundamentals: Databases',3),(8,2,'Практика: Бази даних','Practice: Databases',3),(9,3,'Міні-проєкт','Mini project',3),(10,1,'Основи: Аналіз даних','Fundamentals: Data analysis',4),(11,2,'Практика: Python','Practice: Python',4),(12,3,'Міні-проєкт','Mini project',4),(13,1,'Основи: Аналіз даних','Fundamentals: Data analysis',5),(14,2,'Практика: Аналіз даних','Practice: Data analysis',5),(15,3,'Міні-проєкт','Mini project',5),(16,1,'Основи: Веб','Fundamentals: Web',6),(17,2,'Практика: Веб','Practice: Web',6),(18,3,'Міні-проєкт','Mini project',6),(19,1,'Основи: Веб','Fundamentals: Web',7),(20,2,'Практика: Веб','Practice: Web',7),(21,3,'Міні-проєкт','Mini project',7),(22,1,'Основи: Англійська','Fundamentals: English',8),(23,2,'Практика: Англійська','Practice: English',8),(24,3,'Міні-проєкт','Mini project',8);
/*!40000 ALTER TABLE `core_module` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_moduleprogress`
--

DROP TABLE IF EXISTS `core_moduleprogress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_moduleprogress` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `completed_at` datetime(6) NOT NULL,
  `enrollment_id` bigint NOT NULL,
  `module_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_module_progress` (`enrollment_id`,`module_id`),
  KEY `core_moduleprogress_module_id_a907287f_fk_core_module_id` (`module_id`),
  KEY `core_moduleprogress_enrollment_id_a59bb152` (`enrollment_id`),
  KEY `core_moduleprogress_completed_at_b982518e` (`completed_at`),
  CONSTRAINT `core_moduleprogress_enrollment_id_a59bb152_fk_core_enrollment_id` FOREIGN KEY (`enrollment_id`) REFERENCES `core_enrollment` (`id`),
  CONSTRAINT `core_moduleprogress_module_id_a907287f_fk_core_module_id` FOREIGN KEY (`module_id`) REFERENCES `core_module` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_moduleprogress`
--

LOCK TABLES `core_moduleprogress` WRITE;
/*!40000 ALTER TABLE `core_moduleprogress` DISABLE KEYS */;
INSERT INTO `core_moduleprogress` VALUES (1,'2026-10-13 07:02:03.242547',1,1),(2,'2026-10-13 07:02:03.247206',1,2),(3,'2026-10-13 07:02:03.251610',1,3),(4,'2026-10-13 07:02:03.263294',2,4);
/*!40000 ALTER TABLE `core_moduleprogress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_notification`
--

DROP TABLE IF EXISTS `core_notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_notification` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_read` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `core_notification_code_fe90977e` (`code`),
  KEY `notif_user_read_idx` (`user_id`,`is_read`),
  CONSTRAINT `core_notification_user_id_6e341aac_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_notification`
--

LOCK TABLES `core_notification` WRITE;
/*!40000 ALTER TABLE `core_notification` DISABLE KEYS */;
INSERT INTO `core_notification` VALUES (1,'n3',0,'2026-10-13 07:02:02.168783',1),(2,'n2',0,'2026-10-13 07:02:03.294415',1),(3,'n3',0,'2026-10-13 09:37:31.199838',2),(4,'n1',0,'2026-10-13 09:38:12.206000',2);
/*!40000 ALTER TABLE `core_notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_prerequisite`
--

DROP TABLE IF EXISTS `core_prerequisite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_prerequisite` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `min_level` smallint unsigned NOT NULL,
  `course_id` bigint NOT NULL,
  `skill_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_course_prereq` (`course_id`,`skill_id`),
  KEY `core_prerequisite_skill_id_8791abd4_fk_core_skill_id` (`skill_id`),
  KEY `core_prerequisite_course_id_31684edf` (`course_id`),
  CONSTRAINT `core_prerequisite_course_id_31684edf_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`),
  CONSTRAINT `core_prerequisite_skill_id_8791abd4_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`),
  CONSTRAINT `core_prerequisite_chk_1` CHECK ((`min_level` >= 0)),
  CONSTRAINT `prereq_min_level_1` CHECK ((`min_level` >= 1))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_prerequisite`
--

LOCK TABLES `core_prerequisite` WRITE;
/*!40000 ALTER TABLE `core_prerequisite` DISABLE KEYS */;
INSERT INTO `core_prerequisite` VALUES (4,2,2,1),(5,2,4,1),(6,3,5,1);
/*!40000 ALTER TABLE `core_prerequisite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_profile`
--

DROP TABLE IF EXISTS `core_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_profile` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `display_name` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `goal` varchar(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `weekly_hours` smallint unsigned NOT NULL,
  `preferred_format` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reminders` tinyint(1) NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `core_profile_user_id_bf8ada58_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `core_profile_chk_1` CHECK ((`weekly_hours` >= 0)),
  CONSTRAINT `profile_weekly_hours_1_30` CHECK (((`weekly_hours` >= 1) and (`weekly_hours` <= 30)))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_profile`
--

LOCK TABLES `core_profile` WRITE;
/*!40000 ALTER TABLE `core_profile` DISABLE KEYS */;
INSERT INTO `core_profile` VALUES (1,'Demo','g1',6,'prac',1,1),(2,'dima','g1',30,'prac',1,2);
/*!40000 ALTER TABLE `core_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_profile_interests`
--

DROP TABLE IF EXISTS `core_profile_interests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_profile_interests` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `profile_id` bigint NOT NULL,
  `interest_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `core_profile_interests_profile_id_interest_id_121c02f1_uniq` (`profile_id`,`interest_id`),
  KEY `core_profile_interests_interest_id_9944bc46_fk_core_interest_id` (`interest_id`),
  CONSTRAINT `core_profile_interests_interest_id_9944bc46_fk_core_interest_id` FOREIGN KEY (`interest_id`) REFERENCES `core_interest` (`id`),
  CONSTRAINT `core_profile_interests_profile_id_049b9d41_fk_core_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `core_profile` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_profile_interests`
--

LOCK TABLES `core_profile_interests` WRITE;
/*!40000 ALTER TABLE `core_profile_interests` DISABLE KEYS */;
INSERT INTO `core_profile_interests` VALUES (1,1,1),(2,1,2),(3,1,5),(4,2,1),(5,2,2),(6,2,6),(7,2,7);
/*!40000 ALTER TABLE `core_profile_interests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_recentview`
--

DROP TABLE IF EXISTS `core_recentview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_recentview` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `viewed_at` datetime(6) NOT NULL,
  `course_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_recent_view` (`user_id`,`course_id`),
  KEY `core_recentview_course_id_1c17ec2b_fk_core_course_id` (`course_id`),
  KEY `core_recentview_user_id_610abd03` (`user_id`),
  KEY `recent_user_idx` (`user_id`,`viewed_at` DESC),
  CONSTRAINT `core_recentview_course_id_1c17ec2b_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`),
  CONSTRAINT `core_recentview_user_id_610abd03_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_recentview`
--

LOCK TABLES `core_recentview` WRITE;
/*!40000 ALTER TABLE `core_recentview` DISABLE KEYS */;
INSERT INTO `core_recentview` VALUES (1,'2026-10-13 07:02:03.280095',3,1),(2,'2026-10-13 07:02:03.288034',6,1),(3,'2026-10-13 07:13:39.474849',1,1);
/*!40000 ALTER TABLE `core_recentview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_savedcourse`
--

DROP TABLE IF EXISTS `core_savedcourse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_savedcourse` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `course_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_saved_course` (`user_id`,`course_id`),
  KEY `core_savedcourse_course_id_cd911f0b_fk_core_course_id` (`course_id`),
  KEY `core_savedcourse_user_id_d535cf16` (`user_id`),
  CONSTRAINT `core_savedcourse_course_id_cd911f0b_fk_core_course_id` FOREIGN KEY (`course_id`) REFERENCES `core_course` (`id`),
  CONSTRAINT `core_savedcourse_user_id_d535cf16_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_savedcourse`
--

LOCK TABLES `core_savedcourse` WRITE;
/*!40000 ALTER TABLE `core_savedcourse` DISABLE KEYS */;
INSERT INTO `core_savedcourse` VALUES (1,'2026-10-13 07:02:03.272055',4,1);
/*!40000 ALTER TABLE `core_savedcourse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_skill`
--

DROP TABLE IF EXISTS `core_skill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_skill` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_uk` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_skill`
--

LOCK TABLES `core_skill` WRITE;
/*!40000 ALTER TABLE `core_skill` DISABLE KEYS */;
INSERT INTO `core_skill` VALUES (1,'python','Python','Python'),(2,'web','Веб','Web'),(3,'db','Бази даних','Databases'),(4,'data','Аналіз даних','Data analysis'),(5,'eng','Англійська','English');
/*!40000 ALTER TABLE `core_skill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_userskill`
--

DROP TABLE IF EXISTS `core_userskill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_userskill` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `current_level` smallint unsigned NOT NULL,
  `desired_level` smallint unsigned NOT NULL,
  `skill_id` bigint NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_skill` (`user_id`,`skill_id`),
  KEY `core_userskill_skill_id_b5a74b63_fk_core_skill_id` (`skill_id`),
  KEY `core_userskill_user_id_9ea46a66` (`user_id`),
  KEY `userskill_user_idx` (`user_id`,`skill_id`),
  CONSTRAINT `core_userskill_skill_id_b5a74b63_fk_core_skill_id` FOREIGN KEY (`skill_id`) REFERENCES `core_skill` (`id`),
  CONSTRAINT `core_userskill_user_id_9ea46a66_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `core_userskill_chk_1` CHECK ((`current_level` >= 0)),
  CONSTRAINT `core_userskill_chk_2` CHECK ((`desired_level` >= 0)),
  CONSTRAINT `userskill_cur_lte_5` CHECK ((`current_level` <= 5)),
  CONSTRAINT `userskill_want_lte_5` CHECK ((`desired_level` <= 5))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_userskill`
--

LOCK TABLES `core_userskill` WRITE;
/*!40000 ALTER TABLE `core_userskill` DISABLE KEYS */;
INSERT INTO `core_userskill` VALUES (1,3,4,1,1),(2,2,3,2,1),(3,2,3,3,1),(4,1,3,4,1),(5,3,4,5,1),(6,4,0,1,2),(7,2,1,2,2),(8,4,3,3,2),(9,1,2,4,2),(10,1,3,5,2);
/*!40000 ALTER TABLE `core_userskill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE utf8mb4_unicode_ci,
  `object_repr` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(20,'core','agentknowledge'),(21,'core','chatmessage'),(22,'core','chatsession'),(7,'core','course'),(14,'core','courseskill'),(10,'core','enrollment'),(8,'core','interest'),(11,'core','module'),(15,'core','moduleprogress'),(12,'core','notification'),(18,'core','prerequisite'),(13,'core','profile'),(16,'core','recentview'),(17,'core','savedcourse'),(9,'core','skill'),(19,'core','userskill'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2026-10-13 07:01:12.860626'),(2,'auth','0001_initial','2026-10-13 07:01:13.933797'),(3,'admin','0001_initial','2026-10-13 07:01:14.181307'),(4,'admin','0002_logentry_remove_auto_add','2026-10-13 07:01:14.194090'),(5,'admin','0003_logentry_add_action_flag_choices','2026-10-13 07:01:14.205178'),(6,'contenttypes','0002_remove_content_type_name','2026-10-13 07:01:14.403782'),(7,'auth','0002_alter_permission_name_max_length','2026-10-13 07:01:14.522594'),(8,'auth','0003_alter_user_email_max_length','2026-10-13 07:01:14.564061'),(9,'auth','0004_alter_user_username_opts','2026-10-13 07:01:14.577703'),(10,'auth','0005_alter_user_last_login_null','2026-10-13 07:01:14.682814'),(11,'auth','0006_require_contenttypes_0002','2026-10-13 07:01:14.687503'),(12,'auth','0007_alter_validators_add_error_messages','2026-10-13 07:01:14.699689'),(13,'auth','0008_alter_user_username_max_length','2026-10-13 07:01:14.827950'),(14,'auth','0009_alter_user_last_name_max_length','2026-10-13 07:01:14.951170'),(15,'auth','0010_alter_group_name_max_length','2026-10-13 07:01:14.984802'),(16,'auth','0011_update_proxy_permissions','2026-10-13 07:01:15.007730'),(17,'auth','0012_alter_user_first_name_max_length','2026-10-13 07:01:15.120697'),(18,'core','0001_initial','2026-10-13 07:01:18.309022'),(19,'core','0002_agentknowledge_chatmessage_chatsession_and_more','2026-10-13 07:01:22.448814'),(20,'sessions','0001_initial','2026-10-13 07:01:22.502032');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('9ursd97lxa2ukgteqyk3xd0nj45pozh3','.eJxVjDsOwjAQBe_iGln-J0tJzxms9e6aBFAixUmFuDtESgHtm5n3Uhm3dchbkyWPrM7KqtPvVpAeMu2A7zjdZk3ztC5j0buiD9r0dWZ5Xg7372DANnzrFCBxTx4iSwESiRXB21o6MYGsE8O-ig_RGhswdUgVUu2BQFic69T7A_nROHo:1xGWhd:1INJxJ7HJY6mmZ4QwV7Vz5agnB52iP_8dzfWR9pqwC8','2026-10-27 07:13:37.900071'),('9xu2mhsbaqcs1jkotzw44f11ajbdbit1','.eJxVjDsOwjAQBe_iGln-J0tJzxms9e6aBFAixUmFuDtESgHtm5n3Uhm3dchbkyWPrM7KqtPvVpAeMu2A7zjdZk3ztC5j0buiD9r0dWZ5Xg7372DANnzrFCBxTx4iSwESiRXB21o6MYGsE8O-ig_RGhswdUgVUu2BQFic69T7A_nROHo:1xGWiZ:6Np5rGKyqSQcWu1ZvDrf9ORl7HpG4DiJ4xGLP0DKIK8','2026-10-27 07:14:35.786197'),('hgwgq0fl2xvsobpyifu47kk2vvhlzj1w','.eJxVjDsOwjAQBe_iGln-J0tJzxms9e6aBFAixUmFuDtESgHtm5n3Uhm3dchbkyWPrM7KqtPvVpAeMu2A7zjdZk3ztC5j0buiD9r0dWZ5Xg7372DANnzrFCBxTx4iSwESiRXB21o6MYGsE8O-ig_RGhswdUgVUu2BQFic69T7A_nROHo:1xGWjp:P4pf5NJtbOO8Zhexa8uSRKJtpJL3ylu2ALLN6-_ES7E','2026-10-27 07:15:53.637923'),('ingyahcr2mm3a94skr202n2j26patp4q','.eJxVjMsOwiAQRf-FtSHy6AAu3fcbCDNDpWogKe3K-O_apAvd3nPOfYmYtrXEreclziwuQonT74aJHrnugO-p3pqkVtdlRrkr8qBdjo3z83q4fwcl9fKtQWmfiBwzWpiM0xkml3wImpgANVhQ7IzX3jBTGJAdoibINJzZWSPeH_FiOEM:1xGsdG:6Py21kiug7_mIHKG8pIJwdhEm5RlpneBoPw-RWhSGKU','2026-10-28 06:38:34.399344'),('mabmw6d4xixyxg8eosg80k2l4lmgxy28','.eJxVjEEOwiAQRe_C2hCgUgaX7nsGMsyAVA0kpV0Z765NutDtf-_9lwi4rSVsPS1hZnERRpx-t4j0SHUHfMd6a5JaXZc5yl2RB-1yapye18P9OyjYy7cGbYEwG4UmkbPGD1pnGvGsyPIIAKyj5qgHdsb55DNwNDBYBaQwIoj3B9uNN88:1xGYwt:i6EmD--k7QeAaxyY8zsOmfamlBdvjtJV2G6XfZQt1oY','2026-10-27 09:37:31.213451');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'learnova'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-15  9:08:17
