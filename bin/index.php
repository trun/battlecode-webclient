<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<title>Battlecode Online Match Viewer</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="language" content="en" />
	<meta name="description" content="" />
	<meta name="keywords" content="" />
	
	<script src="/2010/js/swfobject.js" type="text/javascript"></script>
	<script type="text/javascript">
		var flashvars = {
			match_num: <?=$_GET['match_num']?>
		};
		var params = {
			menu: "false",
			scale: "noScale",
			bgcolor: "#FFFFFF",
			allowscriptaccess: "always",
			allowfullscreen: "true"
		};
		swfobject.embedSWF("/2010/watch/webclient.swf", "altContent", "100%", "100%", "10.0.0", "expressInstall.swf", flashvars, params);
	</script>
	<style>
		html, body { height:100%; }
		body { margin:0; }
	</style>
</head>
<body>
	<div id="altContent">
		<h1>Battlecode 2009</h1>
		<p>The Battlecode WebClient requires Flash Player 10 or later</p>
		<p><a href="http://www.adobe.com/go/getflashplayer"><img 
			src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" 
			alt="Get Adobe Flash player" /></a></p>
	</div>
</body>
</html>