<?php
/*
	Example:
	http://www.neutrino-images.de/neutrino-images/get-image.php?boxtype=coolstream&boxmodel=kronos(&debug)
*/

$boxtype = trim($_GET["boxtype"]);
$boxtype_sc = ""; # autofilled
$boxseries = trim($_GET["boxseries"]);
$boxmodel = trim($_GET["boxmodel"]);

$image_version = "???"; # wildcard for version (e.g. 320)
$image_date = "????????????"; # wildcard for date (e.g. 201601012359)
$image_type = "release";

# convert strings to lower case
$boxtype = strtolower($boxtype);
$boxtype_sc = strtolower($boxtype_sc);
$boxseries = strtolower($boxseries);
$boxmodel = strtolower($boxmodel);
$image_type = strtolower($image_type);

$debug = false;
if (isset($_GET["debug"]))
{
	$_debug = trim($_GET["debug"]);
	$_debug = strtolower($_debug);
	if ($_debug != "false" && $_debug != "no")
		$debug = true;
}

if ($boxtype == "coolstream" || $boxtype == "cst")
{
	# CST
	$boxtype_sc = "cst";
}

# release/ni320-YYYYMMDDHHMM-cst-kronos.img
$directory = $image_type;
if ($debug)
	$directory .= "/debug";
$pattern = $directory . "/ni" . $image_version . "-" . $image_date . "-" . $boxtype_sc . "-" . $boxmodel . ".img";

# find last (newest) image
$last_mod = 0;
$last_image = "";
foreach (glob($pattern) as $image)
{
	if (is_file($image) && filectime($image) > $last_mod)
	{
		$last_mod = filectime($image);
		$last_image = $image;
	}
}

if (empty($last_image))
{
	# send error
	header('HTTP/1.0 404 Not Found');
	die("<h1>404</h1>\nImage not found.");
}
else
{
	# send image
	header("Content-Type: application/octet-stream");
	header("Content-Disposition: attachment; filename=\"$last_image\"");
	readfile($last_image);
}
?>