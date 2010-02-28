<?
	require_once('patErrorManager.php');
	require_once('patTemplate.php');
    $tmpl =new patTemplate();;
    $tmpl->setRoot( dirname( __FILE__ ) . '/xmltemplates' );
	$tmpl->readTemplatesFromFile("category.tpl");
 	$db = new mysqli('localhost','root','valium10','mambolfs') or die("Could not connect");
	$catID = (isset($_REQUEST['id'])) ? $_REQUEST['id'] : 0 ;

	$db->multi_query("call getLFSCategoryDetails($catID)") or die("Error accessing data.");
	$parents=$db->store_result();
	$db->next_result();
	$children=$db->store_result();
	$db->next_result();
	$galleries=$db->store_result();
	$db->next_result();

	while (list($pid,$pname,$pdescription)=$parents->fetch_array())
	{
		$tmpl->addVar("parents","CATID",$pid);
		$tmpl->addVar("parents","CATNAME",$pname);
		$tmpl->parseTemplate("parents", "a"); 			
	}
	
	while (list($cid,$cname,$cdescription,$numGals,$numPics)=$children->fetch_array())
	{
		$tmpl->addVar("children","CATNAME",$cname);
		$tmpl->addVar("children","CATID",$cid);
		$tmpl->addVar("children","NUMGALLERIES",$numGals);
		$tmpl->addVar("children","NUMPICTURES",$numPics);
		$tmpl->addVar("children","DESCRIPTION",$cdescription);
		$tmpl->parseTemplate("children", "a");
	}
	
	while (list($gid,$gname,$gdate,$gthumb)=$galleries->fetch_array())
	{
		$thumb="http://www.londonfetishscene.com/galleries/".$gthumb;
	    $tmpl->addVar("galleries","GALNAME",$gname);
	    $tmpl->addVar("galleries","GALID",$gid);
	    $tmpl->addVar("galleries","GALTHUMB",$thumb);
		$tmpl->parseTemplate("galleries", "a");		
	}
	
	$parents->close();
	$children->close();
	$galleries->close();
	$tmpl->displayParsedTemplate('category');
?>