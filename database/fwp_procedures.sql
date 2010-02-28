USE fairweatherpunk;

DROP PROCEDURE IF EXISTS getCategoryDetails;
DROP PROCEDURE IF EXISTS addCollectionItem;
DROP PROCEDURE IF EXISTS addCollection;
DROP PROCEDURE IF EXISTS addCategory;
DROP PROCEDURE IF EXISTS deleteCategory;
DROP PROCEDURE IF EXISTS getCollectionItems;
DROP PROCEDURE IF EXISTS addItemType;
DROP PROCEDURE IF EXISTS addServer;
DROP PROCEDURE IF EXISTS addTagForItem;
DROP PROCEDURE IF EXISTS getItemDetails;
DROP PROCEDURE IF EXISTS getTags;
DROP PROCEDURE IF EXISTS getCollectionOnTag;
DROP PROCEDURE IF EXISTS addMetaForItem;
DROP PROCEDURE IF EXISTS addMetaForCollection;
DROP PROCEDURE IF EXISTS searchMeta;
DROP PROCEDURE IF EXISTS getCollectionsWithMeta;
DROP PROCEDURE IF EXISTS getItemsWithMeta;
DROP PROCEDURE IF EXISTS getCategoryHeirarchy;
DROP PROCEDURE IF EXISTS getLeafNodes;
DROP PROCEDURE IF EXISTS getMetaValues;
DROP PROCEDURE IF EXISTS publishItem;
DROP PROCEDURE IF EXISTS unpublishItem;

DROP FUNCTION IF EXISTS addTag;
DROP FUNCTION IF EXISTS getMetaForItem;
DROP FUNCTION IF EXISTS addMetaValue;
DROP FUNCTION IF EXISTS addMetaName;
DROP FUNCTION IF EXISTS getTagsForItem;

/*
	Stored Procedures
*/
DELIMITER $$

CREATE PROCEDURE getCategoryDetails (IN c_id INT)
BEGIN

DECLARE category_id INT;

SELECT id INTO category_id FROM fwp_categories WHERE c_id=id;

IF category_id IS NOT NULL THEN

	SELECT c2.id, c2.name, c2.description
		FROM fwp_categories c1
		INNER JOIN fwp_categories c2
		ON c1.left_side BETWEEN c2.left_side and c2.right_side
		WHERE c1.id=c_id
		ORDER BY c2.left_side ASC;
	
	SELECT c.id, c.name, c.description, c.num_collections, c.num_items, s.base_url as preview_base, i.id as preview_item, t.name as preview_type
		FROM fwp_categories c, fwp_items i, fwp_servers s, fwp_item_types t
		WHERE c.parent_category_id=c_id
		AND   c.preview=i.id
		AND   s.id=i.server_id
		AND   i.type=t.id
		ORDER BY c.name;
	
	SELECT c.id, c.name, c.num_items, s.base_url as preview_base, i.id as preview_item, t.name as preview_type
		FROM fwp_collections c, fwp_items i, fwp_servers s, fwp_item_types t
		WHERE c.category_id=c_id
		AND   c.preview=i.id
		AND   i.type=t.id
		AND   s.id=i.server_id;
END IF;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addCollectionItem (IN col_id INT, IN server_id INT, IN item_date DATETIME, IN add_date DATETIME, IN type VARCHAR(20), IN path VARCHAR(255), IN item_order int, IN is_preview INT)
BEGIN

DECLARE item_id INT;
DECLARE cat_id INT;
DECLARE type_id INT;

IF ISNULL(add_date) THEN
	 SET add_date=NOW();
END IF;

SELECT id INTO type_id FROM fwp_item_types WHERE name=type;

INSERT INTO fwp_items (server_id,item_date,insert_date,type,path) VALUES (server_id,item_date,add_date,type_id,path);
SELECT LAST_INSERT_ID() INTO item_id;

SELECT category_id INTO cat_id FROM fwp_collections WHERE id=col_id;

INSERT INTO fwp_collection_items (item_id,collection_id,item_order) VALUES (item_id,col_id,item_order);

UPDATE fwp_collections SET num_items=num_items+1 WHERE id=col_id;
IF is_preview=1 THEN
	UPDATE fwp_collections SET preview=item_id WHERE id=col_id;
END IF;

UPDATE fwp_categories c0, 
	(SELECT c2.id 
		FROM fwp_categories c1
	  	INNER JOIN fwp_categories c2
	  	ON c1.left_side BETWEEN c2.left_side AND c2.right_side
	  	WHERE c1.id=cat_id) p
	SET c0.num_items=c0.num_items+1 where c0.id = p.id;

SELECT item_id;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addCollection (IN cat_id INT, IN col_date DATETIME, IN col_name VARCHAR(255))
BEGIN

INSERT INTO fwp_collections (category_id,`name`,col_date,insert_date) VALUES (cat_id,col_name,col_date,NOW()) ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id);

SELECT LAST_INSERT_ID();

UPDATE fwp_categories c0, 
	(SELECT c2.id 
		FROM fwp_categories c1
	  	INNER JOIN fwp_categories c2
	  	ON c1.left_side BETWEEN c2.left_side AND c2.right_side
	  	WHERE c1.id=cat_id) p
	SET c0.num_collections=c0.num_collections+1 where c0.id = p.id;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addCategory
	(IN c_name VARCHAR(255), 
	 IN p_id INT, 
	 IN c_id INT,
	 IN c_description TEXT,
	 IN c_information TEXT,
	 IN c_contact VARCHAR(255),
	 IN c_url VARCHAR(255),
	 IN c_sample VARCHAR(255),
	 IN c_portrait VARCHAR(255),
	 IN c_preview INT(10))
BEGIN

DECLARE insert_right INT DEFAULT 0;

SELECT right_side INTO insert_right FROM fwp_categories WHERE id=p_id;

UPDATE fwp_categories
	SET left_side = IF ( left_side>insert_right, left_side+2, left_side),
       right_side = IF (right_side>=insert_right, right_side+2, right_side)
	WHERE right_side>=insert_right;

INSERT INTO fwp_categories 
		(id,parent_category_id,name,left_side,right_side,description,information,contact,website,sample,portrait,preview)
	VALUES 
		(c_id,p_id,c_name,insert_right,(insert_right+1),c_description,c_information,c_contact,c_url,c_sample,c_portrait,c_preview)
	ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id);

SELECT LAST_INSERT_ID();

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE deleteCategory (IN category_id INT)
BEGIN

DECLARE delete_left INT DEFAULT 0;
DECLARE delete_right INT DEFAULT 0;

SELECT 
    left_side, right_side INTO delete_left, delete_right
FROM fwp_categories 
WHERE id=category_id;

UPDATE fwp_categories
	SET left_side = IF ( left_side>delete_left, left_side-2, left_side),
       right_side = IF (right_side>delete_right, right_side-2, right_side)
	WHERE right_side>delete_right;

DELETE FROM fwp_categories WHERE id=category_id;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE getCollectionItems(IN c_id INT)
BEGIN

DECLARE parent_id INT;
DECLARE n_items INT;
DECLARE coll_name VARCHAR(255);


SELECT category_id,name,num_items INTO parent_id,coll_name,n_items FROM fwp_collections WHERE id=c_id;

IF parent_id IS NOT NULL THEN
	SELECT coll_name,n_items;

	SELECT
		c2.id, c2.name, c2.description
	FROM fwp_categories c1
	INNER JOIN fwp_categories c2
	ON c1.left_side BETWEEN c2.left_side and c2.right_side
	WHERE c1.id=parent_id
	ORDER BY c2.left_side ASC;

	SELECT 
		i.id, i.published, t.name as type, s.base_url, i.item_date, getMetaForItem(i.id) as meta_data, getTagsForItem(i.id) as tags
	FROM fwp_items i, fwp_item_types t, fwp_collection_items ci, fwp_servers s
	WHERE i.id=ci.item_id 
	AND c_id=ci.collection_id and s.id=i.server_id
	AND i.type=t.id
	ORDER BY ci.item_order ASC;
END IF;
END
$$

/*-------------------------------------------------------------*/

CREATE PROCEDURE getPublishedCollectionItems(IN c_id INT)
BEGIN

DECLARE parent_id INT;
DECLARE n_items INT;
DECLARE coll_name VARCHAR(255);


SELECT category_id,name,num_items INTO parent_id,coll_name,n_items FROM fwp_collections WHERE id=c_id;

IF parent_id IS NOT NULL THEN
	SELECT coll_name,n_items;

	SELECT
		c2.id, c2.name, c2.description
	FROM fwp_categories c1
	INNER JOIN fwp_categories c2
	ON c1.left_side BETWEEN c2.left_side and c2.right_side
	WHERE c1.id=parent_id
	ORDER BY c2.left_side ASC;

	SELECT 
		i.id, t.name as type, s.base_url, i.item_date, getMetaForItem(i.id) as meta_data, getTagsForItem(i.id) as tags
	FROM fwp_items i, fwp_item_types t, fwp_collection_items ci, fwp_servers s
	WHERE i.id=ci.item_id 
	AND c_id=ci.collection_id and s.id=i.server_id
	AND i.type=t.id
	AND i.published=1
	ORDER BY ci.item_order ASC;
END IF;
END
$$

/*------------------------------------------------------------*/

CREATE FUNCTION addTag(tag_name VARCHAR(255)) RETURNS INT
DETERMINISTIC
BEGIN

INSERT INTO fwp_tags (name,used) VALUES (tag_name,1) ON DUPLICATE KEY UPDATE used=used+1, id=LAST_INSERT_ID(id);

RETURN LAST_INSERT_ID();

END

$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addItemType(IN type VARCHAR(20))
BEGIN

INSERT IGNORE INTO fwp_item_types (name) VALUES (type);

END

$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addServer(IN name varchar(255),IN base_url varchar(255), IN base_path varchar(255), IN local CHAR)
BEGIN

INSERT INTO fwp_servers (name,base_url,base_path,local) VALUES (name,base_url,base_path,local);

END

$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addTagForItem (IN item_id int, IN tag_name VARCHAR(255))
BEGIN

INSERT IGNORE INTO fwp_item_tags (item_id,tag_id) VALUES (item_id,addTag(tag_name));

END

$$

/*------------------------------------------------------------*/

CREATE PROCEDURE getItemDetails(IN item_id int)
BEGIN

SELECT 
	item_id, i.path, getMetaForItem(item_id), getTagsForItem(item_id)
FROM fwp_items i
WHERE i.id=item_id;

END

$$

/*------------------------------------------------------------*/

CREATE PROCEDURE getTags()
BEGIN

SELECT id,name,used from fwp_tags;

END
$$

/*------------------------------------------------------------*/

CREATE FUNCTION getTagsForItem(item_id INT) RETURNS TEXT
READS SQL DATA
BEGIN

DECLARE tag_data TEXT;

SELECT GROUP_CONCAT(CONCAT('{##',ft.name,'##}')) INTO tag_data
FROM fwp_item_tags fit
INNER JOIN fwp_tags ft ON ft.id=fit.tag_id
WHERE fit.item_id=item_id;

RETURN tag_data;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE getCollectionOnTag(IN tag_name VARCHAR(255))
BEGIN

DECLARE tag_id INT;

SELECT id INTO tag_id FROM fwp_tags WHERE name=tag_name;

SELECT 
	i.id, i.path, getMetaForItem(i.id), getTagsForItem(i.id)
	FROM fwp_items i
	INNER JOIN fwp_item_tags fit
	WHERE i.id=fit.item_id AND fit.tag_id=tag_id;

END
$$

/*------------------------------------------------------------*/

CREATE FUNCTION addMetaName (meta_name VARCHAR(255)) RETURNS INT
DETERMINISTIC
BEGIN

INSERT INTO fwp_meta (name) VALUES (meta_name) ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id);

RETURN LAST_INSERT_ID();

END
$$

/*------------------------------------------------------------*/

CREATE FUNCTION addMetaValue (meta_value TEXT) RETURNS INT
DETERMINISTIC
BEGIN

INSERT INTO fwp_meta_values (value) VALUES (meta_value) ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id);

RETURN LAST_INSERT_ID();

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addMetaForItem (IN item_id INT, meta_name VARCHAR(255),IN  meta_value TEXT)
BEGIN

INSERT IGNORE INTO fwp_item_meta (item_id,meta_id,value_id) VALUES (item_id,addMetaName(meta_name),addMetaValue(meta_value));

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE addMetaForCollection (IN col_id INT, IN meta_name VARCHAR(255), IN meta_value TEXT)
BEGIN

INSERT IGNORE INTO fwp_collection_meta (col_id,meta_id,value_id) VALUES (col_id,addMetaName(meta_name),addMetaValue(meta_value));

END
$$

/*------------------------------------------------------------*/

CREATE FUNCTION getMetaForItem(item_id INT) RETURNS TEXT
READS SQL DATA
BEGIN

DECLARE meta_data TEXT;

SELECT GROUP_CONCAT(CONCAT('{##',fm.name,'##',fmv.value,'##}')) INTO meta_data
FROM fwp_item_meta fim
INNER JOIN fwp_meta fm ON fm.id=fim.meta_id 
INNER JOIN fwp_meta_values fmv ON fmv.id=fim.value_id
WHERE fim.item_id=item_id;

RETURN meta_data;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE searchMeta(IN meta_name VARCHAR(255), IN search_string VARCHAR(255))
BEGIN

DECLARE meta_id INT;

SELECT id INTO meta_id FROM fwp_meta WHERE name=meta_name;

SELECT i.id, t.name, s.base_url, getMetaForItem(i.id), getTagsForItem(i.id) FROM fwp_items i
INNER JOIN fwp_item_meta fim ON i.id=fim.item_id AND fim.meta_id=meta_id AND fim.value_id IN
	(SELECT id FROM fwp_meta_values fmv WHERE MATCH(fmv.value) AGAINST(search_string IN BOOLEAN MODE))
INNER JOIN fwp_item_types t ON  i.type=t.id
INNER JOIN fwp_servers s ON  s.id=i.server_id;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE getCollectionsWithMeta(IN meta_name VARCHAR(255),IN meta_value VARCHAR(255))
BEGIN

DECLARE mid INT;
DECLARE vid INT;

SELECT id INTO mid FROM fwp_meta WHERE name=meta_name;
SELECT id INTO vid FROM fwp_meta_values WHERE value=meta_value;

SELECT c.id, c.name, c.num_items, s.base_url, i.id as preview_id, t.name as preview_type
	FROM fwp_collections c, fwp_items i, fwp_servers s, fwp_item_types t, fwp_collection_meta fcm
	WHERE c.preview=i.id
	AND   i.type=t.id
	AND   s.id=i.server_id
	AND   fcm.value_id=vid
	AND   fcm.meta_id=mid
	AND   fcm.col_id=c.id;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE getItemsWithMeta(IN meta_name VARCHAR(255), IN meta_value VARCHAR(255))
BEGIN

DECLARE mid INT;
DECLARE vid INT;

SELECT id INTO mid FROM fwp_meta WHERE name=meta_name;
SELECT id INTO vid FROM fwp_meta_values WHERE value=meta_value;

SELECT i.id, t.name, s.base_url, getMetaForItem(i.id), getTagsForItem(i.id)
	FROM fwp_items i, fwp_item_types t, fwp_servers s, fwp_item_meta fim
	WHERE s.id=i.server_id
	AND   fim.value_id=vid
	AND   fim.meta_id=mid
	AND   fim.item_id=i.id;

END
$$

/*------------------------------------------------------------*/
CREATE PROCEDURE getCategoryHeirarchy()
BEGIN

SELECT node.id, COUNT(parent.name) - 1 as depth, node.name
FROM fwp_categories AS node,
fwp_categories AS parent
WHERE node.left_side BETWEEN parent.left_side AND parent.right_side
GROUP BY node.id
ORDER BY node.left_side;

END
$$

/*-----------------------------------------------------------*/
CREATE PROCEDURE getLeafNodes()
BEGIN

SELECT id,name FROM fwp_categories WHERE right_side=left_side+1 ORDER BY name;
END
$$

/*-----------------------------------------------------------*/

CREATE PROCEDURE getMetaValues(IN meta_name VARCHAR(255))
BEGIN

SELECT DISTINCT fmv.id,fmv.value 
FROM fwp_meta_values fmv, fwp_item_meta fim, fwp_meta fm
WHERE fim.meta_id=fm.id AND fim.value_id=fmv.id AND fm.name=meta_name
ORDER BY fmv.value;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE publishItem(IN item_id int)
BEGIN

UPDATE fwp_items SET published=1 WHERE id=item_id;

END
$$

/*------------------------------------------------------------*/

CREATE PROCEDURE unpublishItem(IN item_id int)
BEGIN

UPDATE fwp_items SET published=0 WHERE id=item_id;

END
$$

/*-----------------------------------------------------------*/
DELIMITER ;
/*
 select distinct(mv.value) from fwp_collection_meta cm ,fwp_meta_values mv where mv.id=cm.value_id and cm.meta_id=4
*/
