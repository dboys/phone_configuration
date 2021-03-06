-- MySQL dump 10.13  Distrib 5.5.31, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: users
-- ------------------------------------------------------
-- Server version	5.5.31-0ubuntu0.12.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `html_info`
--

DROP TABLE IF EXISTS `html_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `html_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `proxy_id` text NOT NULL,
  `login_id` text NOT NULL,
  `passwd_id` text NOT NULL,
  `ip` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `html_info`
--

LOCK TABLES `html_info` WRITE;
/*!40000 ALTER TABLE `html_info` DISABLE KEYS */;
INSERT INTO `html_info` VALUES (37,'12015','11375','P11311','192.168.73.193'),(38,'12015','11375','P11311','192.168.73.151'),(39,'12015','11375','P11311','192.168.73.193'),(40,'12015','11375','P11311','192.168.73.151'),(41,'12015','11375','P11311','192.168.73.193'),(42,'12015','11375','P11311','192.168.73.151'),(43,'12015','11375','P11311','192.168.73.193'),(44,'12015','11375','P11311','192.168.73.151'),(45,'12015','11375','P11311','192.168.73.193'),(46,'12015','11375','P11311','192.168.73.151'),(47,'12015','11375','P11311','192.168.73.193'),(48,'12015','11375','P11311','192.168.73.151'),(49,'12015','11375','P11311','192.168.73.193'),(50,'12015','11375','P11311','192.168.73.151'),(51,'12015','11375','P11311','192.168.73.193'),(52,'12015','11375','P11311','192.168.73.151'),(53,'12015','11375','P11311','192.168.73.193'),(54,'12015','11375','P11311','192.168.73.151'),(55,'12015','11375','P11311','192.168.73.193'),(56,'12015','11375','P11311','192.168.73.151'),(57,'12015','11375','P11311','192.168.73.193'),(58,'12015','11375','P11311','192.168.73.151'),(59,'12015','11375','P11311','192.168.73.193'),(60,'12015','11375','P11311','192.168.73.151'),(61,'12015','11375','P11311','192.168.73.193'),(62,'12015','11375','P11311','192.168.73.151'),(63,'12015','11375','P11311','192.168.73.193'),(64,'12015','11375','P11311','192.168.73.151'),(65,'12015','11375','P11311','192.168.73.193'),(66,'12015','11375','P11311','192.168.73.151'),(67,'12015','11375','P11311','192.168.73.193'),(68,'12015','11375','P11311','192.168.73.151'),(69,'12015','11375','P11311','192.168.73.193'),(70,'12015','11375','P11311','192.168.73.151'),(71,'12015','11375','P11311','192.168.73.193'),(72,'12015','11375','P11311','192.168.73.151'),(73,'12015','11375','P11311','192.168.73.193'),(74,'12015','11375','P11311','192.168.73.151'),(75,'12015','11375','P11311','192.168.73.193'),(76,'12015','11375','P11311','192.168.73.151'),(77,'12015','11375','P11311','192.168.73.193'),(78,'12015','11375','P11311','192.168.73.151'),(79,'12015','11375','P11311','192.168.73.193'),(80,'12015','11375','P11311','192.168.73.151'),(81,'12015','11375','P11311','192.168.73.193'),(82,'12015','11375','P11311','192.168.73.193'),(83,'12015','11375','P11311','192.168.73.151'),(84,'12015','11375','P11311','192.168.73.193'),(85,'12015','11375','P11311','192.168.73.151'),(86,'12015','11375','P11311','192.168.73.193'),(87,'12015','11375','P11311','192.168.73.151'),(88,'12015','11375','P11311','192.168.73.193'),(89,'12015','11375','P11311','192.168.73.151'),(90,'12015','11375','P11311','192.168.73.193'),(91,'12015','11375','P11311','192.168.73.151'),(92,'12015','11375','P11311','192.168.73.193'),(93,'12015','11375','P11311','192.168.73.151'),(94,'12015','11375','P11311','192.168.73.193'),(95,'12015','11375','P11311','192.168.73.151'),(96,'12015','11375','P11311','192.168.73.193'),(97,'12015','11375','P11311','192.168.73.151'),(98,'12015','11375','P11311','192.168.73.151'),(99,'12015','11375','P11311','192.168.73.151'),(100,'12015','11375','P11311','192.168.73.151'),(101,'12015','11375','P11311','192.168.73.193'),(102,'12015','11375','P11311','192.168.73.151');
/*!40000 ALTER TABLE `html_info` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `passwd` varchar(20) NOT NULL,
  `ip` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'10000','qwerty1','195.69.76.159'),(2,'10001','qwerty1','195.69.76.159');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-06-05 22:12:31
