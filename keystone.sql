-- MariaDB dump 10.19  Distrib 10.7.1-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: keystone
-- ------------------------------------------------------
-- Server version       10.7.1-MariaDB-1:10.7.1+maria~focal

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `access_rule`
--

DROP TABLE IF EXISTS `access_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_rule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service` varchar(64) DEFAULT NULL,
  `path` varchar(128) DEFAULT NULL,
  `method` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `access_token`
--

DROP TABLE IF EXISTS `access_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_token` (
  `id` varchar(64) NOT NULL,
  `access_secret` varchar(64) NOT NULL,
  `authorizing_user_id` varchar(64) NOT NULL,
  `project_id` varchar(64) NOT NULL,
  `role_ids` text NOT NULL,
  `consumer_id` varchar(64) NOT NULL,
  `expires_at` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_access_token_consumer_id` (`consumer_id`),
  KEY `ix_access_token_authorizing_user_id` (`authorizing_user_id`),
  CONSTRAINT `access_token_ibfk_1` FOREIGN KEY (`consumer_id`) REFERENCES `consumer` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_credential`
--

DROP TABLE IF EXISTS `application_credential`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_credential` (
  `internal_id` int(11) NOT NULL AUTO_INCREMENT,
  `id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `secret_hash` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `user_id` varchar(64) NOT NULL,
  `project_id` varchar(64) DEFAULT NULL,
  `expires_at` bigint(20) DEFAULT NULL,
  `system` varchar(64) DEFAULT NULL,
  `unrestricted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`internal_id`),
  UNIQUE KEY `duplicate_app_cred_constraint` (`user_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_credential_access_rule`
--

DROP TABLE IF EXISTS `application_credential_access_rule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_credential_access_rule` (
  `application_credential_id` int(11) NOT NULL,
  `access_rule_id` int(11) NOT NULL,
  PRIMARY KEY (`application_credential_id`,`access_rule_id`),
  KEY `access_rule_id` (`access_rule_id`),
  CONSTRAINT `application_credential_access_rule_ibfk_1` FOREIGN KEY (`application_credential_id`) REFERENCES `application_credential` (`internal_id`) ON DELETE CASCADE,
  CONSTRAINT `application_credential_access_rule_ibfk_2` FOREIGN KEY (`access_rule_id`) REFERENCES `access_rule` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_credential_role`
--

DROP TABLE IF EXISTS `application_credential_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_credential_role` (
  `application_credential_id` int(11) NOT NULL,
  `role_id` varchar(64) NOT NULL,
  PRIMARY KEY (`application_credential_id`,`role_id`),
  CONSTRAINT `application_credential_role_ibfk_1` FOREIGN KEY (`application_credential_id`) REFERENCES `application_credential` (`internal_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `assignment`
--

DROP TABLE IF EXISTS `assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assignment` (
  `type` enum('UserProject','GroupProject','UserDomain','GroupDomain') NOT NULL,
  `actor_id` varchar(64) NOT NULL,
  `target_id` varchar(64) NOT NULL,
  `role_id` varchar(64) NOT NULL,
  `inherited` tinyint(1) NOT NULL,
  PRIMARY KEY (`type`,`actor_id`,`target_id`,`role_id`,`inherited`),
  KEY `ix_actor_id` (`actor_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`inherited` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `config_register`
--

DROP TABLE IF EXISTS `config_register`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config_register` (
  `type` varchar(64) NOT NULL,
  `domain_id` varchar(64) NOT NULL,
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `consumer`
--

DROP TABLE IF EXISTS `consumer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consumer` (
  `id` varchar(64) NOT NULL,
  `description` varchar(64) DEFAULT NULL,
  `secret` varchar(64) NOT NULL,
  `extra` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `credential`
--

DROP TABLE IF EXISTS `credential`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credential` (
  `id` varchar(64) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `project_id` varchar(64) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `extra` text DEFAULT NULL,
  `key_hash` varchar(64) NOT NULL,
  `encrypted_blob` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `endpoint`
--

DROP TABLE IF EXISTS `endpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `endpoint` (
  `id` varchar(64) NOT NULL,
  `legacy_endpoint_id` varchar(64) DEFAULT NULL,
  `interface` varchar(8) NOT NULL,
  `service_id` varchar(64) NOT NULL,
  `url` text NOT NULL,
  `extra` text DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `region_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `service_id` (`service_id`),
  KEY `fk_endpoint_region_id` (`region_id`),
  CONSTRAINT `endpoint_service_id_fkey` FOREIGN KEY (`service_id`) REFERENCES `service` (`id`),
  CONSTRAINT `fk_endpoint_region_id` FOREIGN KEY (`region_id`) REFERENCES `region` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`enabled` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `endpoint_group`
--

DROP TABLE IF EXISTS `endpoint_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `endpoint_group` (
  `id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `filters` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `federated_user`
--

DROP TABLE IF EXISTS `federated_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federated_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) NOT NULL,
  `idp_id` varchar(64) NOT NULL,
  `protocol_id` varchar(64) NOT NULL,
  `unique_id` varchar(255) NOT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idp_id` (`idp_id`,`protocol_id`,`unique_id`),
  KEY `user_id` (`user_id`),
  KEY `federated_user_protocol_id_fkey` (`protocol_id`,`idp_id`),
  CONSTRAINT `federated_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `federated_user_ibfk_2` FOREIGN KEY (`idp_id`) REFERENCES `identity_provider` (`id`) ON DELETE CASCADE,
  CONSTRAINT `federated_user_protocol_id_fkey` FOREIGN KEY (`protocol_id`, `idp_id`) REFERENCES `federation_protocol` (`id`, `idp_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `federation_protocol`
--

DROP TABLE IF EXISTS `federation_protocol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `federation_protocol` (
  `id` varchar(64) NOT NULL,
  `idp_id` varchar(64) NOT NULL,
  `mapping_id` varchar(64) NOT NULL,
  PRIMARY KEY (`id`,`idp_id`),
  KEY `idp_id` (`idp_id`),
  CONSTRAINT `federation_protocol_ibfk_1` FOREIGN KEY (`idp_id`) REFERENCES `identity_provider` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group`
--

DROP TABLE IF EXISTS `group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group` (
  `id` varchar(64) NOT NULL,
  `domain_id` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `description` text DEFAULT NULL,
  `extra` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_group_name_domain_id` (`domain_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `id_mapping`
--

DROP TABLE IF EXISTS `id_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `id_mapping` (
  `public_id` varchar(64) NOT NULL,
  `domain_id` varchar(64) NOT NULL,
  `local_id` varchar(64) NOT NULL,
  `entity_type` enum('user','group') NOT NULL,
  PRIMARY KEY (`public_id`),
  UNIQUE KEY `domain_id` (`domain_id`,`local_id`,`entity_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `identity_provider`
--

DROP TABLE IF EXISTS `identity_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `identity_provider` (
  `id` varchar(64) NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `description` text DEFAULT NULL,
  `domain_id` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `domain_id` (`domain_id`),
  CONSTRAINT `identity_provider_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `project` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`enabled` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `idp_remote_ids`
--

DROP TABLE IF EXISTS `idp_remote_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `idp_remote_ids` (
  `idp_id` varchar(64) DEFAULT NULL,
  `remote_id` varchar(255) NOT NULL,
  PRIMARY KEY (`remote_id`),
  KEY `idp_id` (`idp_id`),
  CONSTRAINT `idp_remote_ids_ibfk_1` FOREIGN KEY (`idp_id`) REFERENCES `identity_provider` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `implied_role`
--

DROP TABLE IF EXISTS `implied_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `implied_role` (
  `prior_role_id` varchar(64) NOT NULL,
  `implied_role_id` varchar(64) NOT NULL,
  PRIMARY KEY (`prior_role_id`,`implied_role_id`),
  KEY `implied_role_implied_role_id_fkey` (`implied_role_id`),
  CONSTRAINT `implied_role_implied_role_id_fkey` FOREIGN KEY (`implied_role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE,
  CONSTRAINT `implied_role_prior_role_id_fkey` FOREIGN KEY (`prior_role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `limit`
--

DROP TABLE IF EXISTS `limit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `limit` (
  `id` varchar(64) NOT NULL,
  `project_id` varchar(64) DEFAULT NULL,
  `service_id` varchar(255) DEFAULT NULL,
  `region_id` varchar(64) DEFAULT NULL,
  `resource_name` varchar(255) DEFAULT NULL,
  `resource_limit` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `internal_id` int(11) NOT NULL AUTO_INCREMENT,
  `registered_limit_id` varchar(64) DEFAULT NULL,
  `domain_id` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`internal_id`),
  UNIQUE KEY `limit_id_key` (`id`),
  KEY `limit_service_id_fkey` (`service_id`,`region_id`,`resource_name`),
  KEY `registered_limit_id` (`registered_limit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `local_user`
--

DROP TABLE IF EXISTS `local_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `local_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) NOT NULL,
  `domain_id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `failed_auth_count` int(11) DEFAULT NULL,
  `failed_auth_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `domain_id` (`domain_id`,`name`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `local_user_user_id_fkey` (`user_id`,`domain_id`),
  CONSTRAINT `local_user_user_id_fkey` FOREIGN KEY (`user_id`, `domain_id`) REFERENCES `user` (`id`, `domain_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mapping`
--

DROP TABLE IF EXISTS `mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mapping` (
  `id` varchar(64) NOT NULL,
  `rules` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migrate_version`
--

DROP TABLE IF EXISTS `migrate_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrate_version` (
  `repository_id` varchar(250) NOT NULL,
  `repository_path` text DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  PRIMARY KEY (`repository_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nonlocal_user`
--

DROP TABLE IF EXISTS `nonlocal_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nonlocal_user` (
  `domain_id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  PRIMARY KEY (`domain_id`,`name`),
  UNIQUE KEY `ixu_nonlocal_user_user_id` (`user_id`),
  KEY `nonlocal_user_user_id_fkey` (`user_id`,`domain_id`),
  CONSTRAINT `nonlocal_user_user_id_fkey` FOREIGN KEY (`user_id`, `domain_id`) REFERENCES `user` (`id`, `domain_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password`
--

DROP TABLE IF EXISTS `password`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `local_user_id` int(11) NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `self_service` tinyint(1) NOT NULL DEFAULT 0,
  `password_hash` varchar(255) DEFAULT NULL,
  `created_at_int` bigint(20) NOT NULL DEFAULT 0,
  `expires_at_int` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `local_user_id` (`local_user_id`),
  CONSTRAINT `password_ibfk_1` FOREIGN KEY (`local_user_id`) REFERENCES `local_user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy`
--

DROP TABLE IF EXISTS `policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy` (
  `id` varchar(64) NOT NULL,
  `type` varchar(255) NOT NULL,
  `blob` text NOT NULL,
  `extra` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_association`
--

DROP TABLE IF EXISTS `policy_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_association` (
  `id` varchar(64) NOT NULL,
  `policy_id` varchar(64) NOT NULL,
  `endpoint_id` varchar(64) DEFAULT NULL,
  `service_id` varchar(64) DEFAULT NULL,
  `region_id` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `endpoint_id` (`endpoint_id`,`service_id`,`region_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project`
--

DROP TABLE IF EXISTS `project`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project` (
  `id` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `extra` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `domain_id` varchar(64) NOT NULL,
  `parent_id` varchar(64) DEFAULT NULL,
  `is_domain` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_project_name_domain_id` (`domain_id`,`name`),
  KEY `project_parent_id_fkey` (`parent_id`),
  CONSTRAINT `project_domain_id_fkey` FOREIGN KEY (`domain_id`) REFERENCES `project` (`id`),
  CONSTRAINT `project_parent_id_fkey` FOREIGN KEY (`parent_id`) REFERENCES `project` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`enabled` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project_endpoint`
--

DROP TABLE IF EXISTS `project_endpoint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_endpoint` (
  `endpoint_id` varchar(64) NOT NULL,
  `project_id` varchar(64) NOT NULL,
  PRIMARY KEY (`endpoint_id`,`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project_endpoint_group`
--

DROP TABLE IF EXISTS `project_endpoint_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_endpoint_group` (
  `endpoint_group_id` varchar(64) NOT NULL,
  `project_id` varchar(64) NOT NULL,
  PRIMARY KEY (`endpoint_group_id`,`project_id`),
  CONSTRAINT `project_endpoint_group_ibfk_1` FOREIGN KEY (`endpoint_group_id`) REFERENCES `endpoint_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project_tag`
--

DROP TABLE IF EXISTS `project_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_tag` (
  `project_id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`project_id`,`name`),
  UNIQUE KEY `project_id` (`project_id`,`name`),
  CONSTRAINT `project_tag_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `region`
--

DROP TABLE IF EXISTS `region`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `region` (
  `id` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `parent_region_id` varchar(255) DEFAULT NULL,
  `extra` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `registered_limit`
--

DROP TABLE IF EXISTS `registered_limit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `registered_limit` (
  `id` varchar(64) NOT NULL,
  `service_id` varchar(255) DEFAULT NULL,
  `region_id` varchar(64) DEFAULT NULL,
  `resource_name` varchar(255) DEFAULT NULL,
  `default_limit` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `internal_id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`internal_id`),
  UNIQUE KEY `registered_limit_id_key` (`id`),
  KEY `region_id` (`region_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_token`
--

DROP TABLE IF EXISTS `request_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_token` (
  `id` varchar(64) NOT NULL,
  `request_secret` varchar(64) NOT NULL,
  `verifier` varchar(64) DEFAULT NULL,
  `authorizing_user_id` varchar(64) DEFAULT NULL,
  `requested_project_id` varchar(64) NOT NULL,
  `role_ids` text DEFAULT NULL,
  `consumer_id` varchar(64) NOT NULL,
  `expires_at` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_request_token_consumer_id` (`consumer_id`),
  CONSTRAINT `request_token_ibfk_1` FOREIGN KEY (`consumer_id`) REFERENCES `consumer` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `revocation_event`
--

DROP TABLE IF EXISTS `revocation_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `revocation_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain_id` varchar(64) DEFAULT NULL,
  `project_id` varchar(64) DEFAULT NULL,
  `user_id` varchar(64) DEFAULT NULL,
  `role_id` varchar(64) DEFAULT NULL,
  `trust_id` varchar(64) DEFAULT NULL,
  `consumer_id` varchar(64) DEFAULT NULL,
  `access_token_id` varchar(64) DEFAULT NULL,
  `issued_before` datetime NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `revoked_at` datetime NOT NULL,
  `audit_id` varchar(32) DEFAULT NULL,
  `audit_chain_id` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_revocation_event_new_revoked_at` (`revoked_at`),
  KEY `ix_revocation_event_issued_before` (`issued_before`),
  KEY `ix_revocation_event_project_id_issued_before` (`project_id`,`issued_before`),
  KEY `ix_revocation_event_user_id_issued_before` (`user_id`,`issued_before`),
  KEY `ix_revocation_event_audit_id_issued_before` (`audit_id`,`issued_before`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role` (
  `id` varchar(64) NOT NULL,
  `name` varchar(255) NOT NULL,
  `extra` text DEFAULT NULL,
  `domain_id` varchar(64) NOT NULL DEFAULT '<<null>>',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_role_name_domain_id` (`name`,`domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensitive_config`
--

DROP TABLE IF EXISTS `sensitive_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sensitive_config` (
  `domain_id` varchar(64) NOT NULL,
  `group` varchar(255) NOT NULL,
  `option` varchar(255) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`domain_id`,`group`,`option`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service` (
  `id` varchar(64) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `extra` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`enabled` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_provider`
--

DROP TABLE IF EXISTS `service_provider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_provider` (
  `auth_url` varchar(256) NOT NULL,
  `id` varchar(64) NOT NULL,
  `enabled` tinyint(1) NOT NULL,
  `description` text DEFAULT NULL,
  `sp_url` varchar(256) NOT NULL,
  `relay_state_prefix` varchar(256) NOT NULL DEFAULT 'ss:mem:',
  PRIMARY KEY (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`enabled` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_assignment`
--

DROP TABLE IF EXISTS `system_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_assignment` (
  `type` varchar(64) NOT NULL,
  `actor_id` varchar(64) NOT NULL,
  `target_id` varchar(64) NOT NULL,
  `role_id` varchar(64) NOT NULL,
  `inherited` tinyint(1) NOT NULL,
  PRIMARY KEY (`type`,`actor_id`,`target_id`,`role_id`,`inherited`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`inherited` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `token`
--

DROP TABLE IF EXISTS `token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `token` (
  `id` varchar(64) NOT NULL,
  `expires` datetime DEFAULT NULL,
  `extra` text DEFAULT NULL,
  `valid` tinyint(1) NOT NULL,
  `trust_id` varchar(64) DEFAULT NULL,
  `user_id` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_token_expires` (`expires`),
  KEY `ix_token_expires_valid` (`expires`,`valid`),
  KEY `ix_token_user_id` (`user_id`),
  KEY `ix_token_trust_id` (`trust_id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`valid` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trust`
--

DROP TABLE IF EXISTS `trust`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trust` (
  `id` varchar(64) NOT NULL,
  `trustor_user_id` varchar(64) NOT NULL,
  `trustee_user_id` varchar(64) NOT NULL,
  `project_id` varchar(64) DEFAULT NULL,
  `impersonation` tinyint(1) NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `remaining_uses` int(11) DEFAULT NULL,
  `extra` text DEFAULT NULL,
  `expires_at_int` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `duplicate_trust_constraint_expanded` (`trustor_user_id`,`trustee_user_id`,`project_id`,`impersonation`,`expires_at`,`expires_at_int`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`impersonation` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trust_role`
--

DROP TABLE IF EXISTS `trust_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trust_role` (
  `trust_id` varchar(64) NOT NULL,
  `role_id` varchar(64) NOT NULL,
  PRIMARY KEY (`trust_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` varchar(64) NOT NULL,
  `extra` text DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `default_project_id` varchar(64) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `last_active_at` date DEFAULT NULL,
  `domain_id` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ixu_user_id_domain_id` (`id`,`domain_id`),
  KEY `domain_id` (`domain_id`),
  KEY `ix_default_project_id` (`default_project_id`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `project` (`id`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`enabled` in (0,1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_group_membership`
--

DROP TABLE IF EXISTS `user_group_membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_group_membership` (
  `user_id` varchar(64) NOT NULL,
  `group_id` varchar(64) NOT NULL,
  PRIMARY KEY (`user_id`,`group_id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `fk_user_group_membership_group_id` FOREIGN KEY (`group_id`) REFERENCES `group` (`id`),
  CONSTRAINT `fk_user_group_membership_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_option`
--

DROP TABLE IF EXISTS `user_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_option` (
  `user_id` varchar(64) NOT NULL,
  `option_id` varchar(4) NOT NULL,
  `option_value` text DEFAULT NULL,
  PRIMARY KEY (`user_id`,`option_id`),
  CONSTRAINT `user_option_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `whitelisted_config`
--

DROP TABLE IF EXISTS `whitelisted_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `whitelisted_config` (
  `domain_id` varchar(64) NOT NULL,
  `group` varchar(255) NOT NULL,
  `option` varchar(255) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`domain_id`,`group`,`option`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
