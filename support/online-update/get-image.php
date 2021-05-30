<?php
/*
	Example:
	http://www.neutrino-images.de/neutrino-images/get-image.php?boxtype=armbox&boxmodel=hd51(&debug)(&mmc)(&recovery)
*/

$boxtype = trim($_GET["boxtype"]);
$boxtype_sc = ""; # autofilled
$boxseries = trim($_GET["boxseries"]);
$boxmodel = trim($_GET["boxmodel"]);

$debug = false;
$mmc = false;
$recovery = false;

if ($boxmodel == "hd60-mmc" || $boxmodel == "hd61-mmc" || $boxmodel == "multiboxse-mmc")
{
	$boxtype = "armbox";

	if ($boxmodel == "hd60-mmc")
		$boxmodel = "hd60";
	elseif ($boxmodel == "hd61-mmc")
		$boxmodel = "hd61";
	elseif ($boxmodel == "multiboxse-mmc")
		$boxmodel = "multiboxse";

	$mmc = true;
}

$image_version = "???"; # wildcard for version (e.g. 320)
$image_date = "????????????"; # wildcard for date (e.g. 201601012359)
$image_type = "nightly";

$add_str = "";

# convert strings to lower case
$boxtype = strtolower($boxtype);
$boxtype_sc = strtolower($boxtype_sc);
$boxseries = strtolower($boxseries);
$boxmodel = strtolower($boxmodel);
$image_type = strtolower($image_type);

if (isset($_GET["debug"]))
{
	$_debug = trim($_GET["debug"]);
	$_debug = strtolower($_debug);
	if ($_debug != "false" && $_debug != "no")
		$debug = true;
}

if (isset($_GET["mmc"]))
{
	$_mmc = trim($_GET["mmc"]);
	$_mmc = strtolower($_mmc);
	if ($_mmc != "false" && $_mmc != "no")
		$mmc = true;
}

if (isset($_GET["recovery"]))
{
	$_recovery = trim($_GET["recovery"]);
	$_recovery = strtolower($_recovery);
	if ($_recovery != "false" && $_recovery != "no")
		$recovery = true;
}

if ($boxtype == "coolstream" || $boxtype == "cst")
{
	$boxtype_sc = "cst";
	$image_ext = "img";
}
elseif ($boxtype == "armbox" || $boxtype == "arm")
{
	$boxtype_sc = "arm";
	if ($mmc || $recovery)
	{
		if ($boxmodel == "hd60" || $boxmodel == "hd61" || $boxmodel == "multiboxse")
		{
			if ($mmc)
				$add_str = "_single_mmc";
			else
				$add_str = "_multi_recovery";
		}
		else
		{
			$add_str = "_multi_usb";
		}
		$image_ext = "zip";
	}
	else
		$image_ext = "tgz";
}

# release/ni320-YYYYMMDDHHMM-cst-kronos.img
$directory = $image_type;
if ($debug)
	$directory .= "/debug";
$pattern = $directory . "/ni" . $image_version . "-" . $image_date . "-" . $boxtype_sc . "-" . $boxmodel . $add_str . "." . $image_ext;

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
	header('Content-Description: File Transfer');
	header('Content-Type: application/octet-stream');
	header('Content-Disposition: attachment; filename="' . basename($last_image) . '"');
	header('Expires: 0');
	header('Cache-Control: must-revalidate');
	header('Pragma: public');
	header('Content-Length: ' . filesize($last_image));
	readfile($last_image);
}
?>