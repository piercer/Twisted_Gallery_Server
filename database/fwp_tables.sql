DROP DATABASE IF EXISTS  twistedgallery;
CREATE DATABASE twistedgallery;

USE twistedgallery;

CREATE TABLE tg_servers (
	`id`                int(10) unsigned NOT NULL auto_increment,
	`name`				varchar(255) NOT NULL,
	`base_url`			varchar(255) NOT NULL,
	`base_path`			varchar(255) NOT NULL,
	`local`				enum('t','f') default 't',
	PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE tg_categories (
  `id`                 int(10) unsigned NOT NULL auto_increment,
  `parent_category_id` int(10) unsigned,
  `name`               varchar(255) NOT NULL,
  `description`        text NOT NULL,
  `information`        text,
  `contact`            text,
  `website`            varchar(255),
  `sample`             varchar(255),
  `portrait`           varchar(255),
  `preview`            int(10) unsigned,
  `left_side`          int(10) unsigned NOT NULL default 0,
  `right_side`         int(10) unsigned NOT NULL default 1,
  `num_collections`    int(10) unsigned NOT NULL default 0,
  `num_items`       int(10) unsigned NOT NULL default 0,
  `published`			tinyint NOT NULL DEFAULT 1,
  PRIMARY KEY  (`id`),
  KEY `Name` (`name`),
  UNIQUE (`parent_category_id`,`name`)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_item_types (
	`id`            int(10) unsigned NOT NULL auto_increment,
	`name`			varchar(20),
  	PRIMARY KEY  (`id`),
	KEY `Name` (`name`),
  	UNIQUE (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_items (
	`id`            int(10) unsigned NOT NULL auto_increment,
	`server_id`		int(10) unsigned NOT NULL,
	`path`			text,
	`type`			int(10) unsigned NOT NULL,
	`item_date`		datetime,
	`insert_date`	datetime,
	`modify_date`	datetime,
	`published`			tinyint NOT NULL DEFAULT 1,
  	PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_collections (
  `id`              int(10) unsigned NOT NULL auto_increment,
  `name`            varchar(255) collate utf8_bin NOT NULL,
  `category_id`     int(10) unsigned NOT NULL,
  `num_items`       int(10) unsigned NOT NULL default 0,
  `preview`         int(10) unsigned,
  `col_date`  datetime,
  `insert_date`	    datetime,
  `modify_date`	    datetime,
  `published`		tinyint NOT NULL DEFAULT 1,
  PRIMARY KEY  (`id`),
  UNIQUE (`category_id`,`name`,`col_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_collection_items (
  `id`             int(10) unsigned NOT NULL auto_increment,
  `item_id`        int(10) unsigned NOT NULL,
  `collection_id`  int(10) unsigned NOT NULL,
  `item_order`     int(10) unsigned NOT NULL default 0
  `published`	   tinyint NOT NULL DEFAULT 1,
  KEY `item_id` (`item_id`),
  KEY `collection_id` (`collection_id`),
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*
	Meta Data Tables
*/

CREATE TABLE  tg_meta (
  `id`              int(10) unsigned NOT NULL auto_increment,
  `name`            varchar(255) collate utf8_bin NOT NULL UNIQUE,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_meta_values (
  `id`              int(10) unsigned NOT NULL auto_increment,
  `value`           text NOT NULL,
  PRIMARY KEY (`id`), 
  FULLTEXT(value),
  UNIQUE(value(128))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE  tg_item_meta (
  `item_id`	        int(10) unsigned NOT NULL,
  `meta_id`         int(10) unsigned NOT NULL,
  `value_id`        int(10) unsigned NOT NULL,
  UNIQUE (`item_id`,`meta_id`,`value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_collection_meta (
  `col_id`          int(10) unsigned NOT NULL,
  `meta_id`         int(10) unsigned NOT NULL,
  `value_id`        int(10) unsigned NOT NULL,
  UNIQUE (`col_id`,`meta_id`,`value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_collection_item_meta (
  `item_id`         int(10) unsigned NOT NULL,
  `col_id`          int(10) unsigned NOT NULL,
  `meta_id`         int(10) unsigned NOT NULL,
  `value_id`        int(10) unsigned NOT NULL,
  UNIQUE (`item_id`,`col_id`,`meta_id`,`value_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*
	Tag Tables
*/

CREATE TABLE  tg_tags (
  `id`              int(10) unsigned NOT NULL auto_increment,
  `name`            varchar(255) collate utf8_bin NOT NULL UNIQUE,
  `used`           int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_item_tags (
  `item_id`         int(10) unsigned NOT NULL,
  `tag_id`          int(10) unsigned NOT NULL,
  PRIMARY KEY (item_id,tag_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_collection_tags (
  `id`              int(10) unsigned NOT NULL auto_increment,
  `tag_id`          int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

CREATE TABLE  tg_collection_item_tags (
  `id`              int(10) unsigned NOT NULL auto_increment,
  `tag_id`          int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
