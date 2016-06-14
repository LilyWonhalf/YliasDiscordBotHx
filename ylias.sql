-- phpMyAdmin SQL Dump
-- version 3.4.11.1deb2+deb7u1
-- http://www.phpmyadmin.net

--
-- Database: `ylias`
--

-- --------------------------------------------------------

--
-- Table structure for table `channel`
--

CREATE TABLE IF NOT EXISTS `channel` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `joke`
--

CREATE TABLE IF NOT EXISTS `joke` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `meme`
--

CREATE TABLE IF NOT EXISTS `meme` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `permission`
--

CREATE TABLE IF NOT EXISTS `permission` (
  `id_user` varchar(255) NOT NULL,
  `id_channel` varchar(255) NOT NULL,
  `id_server` varchar(255) NOT NULL,
  `command` varchar(255) NOT NULL,
  `granted` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_user`,`id_channel`,`id_server`,`command`),
  KEY `id_server` (`id_server`),
  KEY `id_channel` (`id_channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `server`
--

CREATE TABLE IF NOT EXISTS `server` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `server_lang`
--

CREATE TABLE IF NOT EXISTS `server_lang` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_server` varchar(255) NOT NULL,
  `lang` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_server` (`id_server`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tag_blacklist`
--

CREATE TABLE IF NOT EXISTS `tag_blacklist` (
  `id_server` varchar(255) NOT NULL,
  `tag` varchar(255) NOT NULL,
  PRIMARY KEY (`id_server`,`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `permission`
--
ALTER TABLE `permission`
  ADD CONSTRAINT `permission_ibfk_3` FOREIGN KEY (`id_channel`) REFERENCES `channel` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `permission_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `permission_ibfk_2` FOREIGN KEY (`id_server`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `server_lang`
--
ALTER TABLE `server_lang`
  ADD CONSTRAINT `server_lang_ibfk_1` FOREIGN KEY (`id_server`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tag_blacklist`
--
ALTER TABLE `tag_blacklist`
  ADD CONSTRAINT `tag_blacklist_ibfk_1` FOREIGN KEY (`id_server`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
