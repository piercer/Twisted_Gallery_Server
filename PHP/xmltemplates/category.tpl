<patTemplate:tmpl name="category">
<category id="{CATID}" name="{CATNAME}">
	<description><![CDATA[{DESCRIPTION}]]></description>
	<parents>
		<patTemplate:tmpl name="parents">
		<category id="{CATID}" name="{CATNAME}"/>
		</patTemplate:tmpl>
	</parents>
	<subcats>
		<patTemplate:tmpl name="children">
		<category id="{CATID}" name="{CATNAME}" num_gal="{NUMGALLERIES}" num_pic="{NUMPICTURES}">
			<description><![CDATA[{DESCRIPTION}]]></description>
		</category>
		</patTemplate:tmpl>
	</subcats>
	<galleries>
		<patTemplate:tmpl name="galleries">
  		<gallery thumb="{GALTHUMB}" id="{GALID}" name="{GALNAME}"/>
		</patTemplate:tmpl>
	</galleries>
</category>
</patTemplate:tmpl>