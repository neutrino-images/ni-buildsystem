<?php
header('Content-Type: text/plain');

# uncomment next line to deactivate online update
#die();

$boxtype = ""; # currently unused
$boxtype_sc = "";
$boxseries = "";
$boxmodel = "";

$image_type = "";
$image_type = trim($_GET["image_type"]);
$image_type = strtolower($image_type);

$revision = "";
$revision = trim($_GET["revision"]);

$boxname = "";
$boxname = trim($_GET["boxname"]);
$boxname = strtolower($boxname);

$chip_type = "";
$chip_type = trim($_GET["chip_type"]);

if ($revision == 1) // libstb-hal
{
	if ($boxname == "hd51")
	{
		$boxtype_sc = "arm";
		$boxseries = "hd51";
		$boxmodel = "hd51";
	}
	elseif ($boxname == "bre2ze4k")
	{
		$boxtype_sc = "arm";
		$boxseries = "hd51";
		$boxmodel = "bre2ze4k";
	}
	elseif ($boxname == "h7")
	{
		$boxtype_sc = "arm";
		$boxseries = "hd51";
		$boxmodel = "h7";
	}
	elseif ($boxname == "solo4k" || $boxname == "duo4k" || $boxname == "ultimo4k" || $boxname == "zero4k" || $boxname == "uno4k" || $boxname == "uno4kse")
	{
		$boxtype_sc = "arm";
		$boxseries = "vu" .  $boxname;
		$boxmodel = "vu" . $boxname;
	}
}
elseif ($revision == 6 || $revision == 7 || $revision == 8 || $revision == 10)
{
	# CST - HD1, BSE, Neo, Neo², Zee
	$boxtype_sc = "cst";
	$boxseries = "hd1";
	$boxmodel = "nevis";
}
elseif ($revision == 9)
{
	# CST - Tank
	$boxtype_sc = "cst";
	$boxseries = "hd2";
	$boxmodel = "apollo";
}
elseif ($revision == 11)
{
	# CST - Trinity
	$boxtype_sc = "cst";
	$boxseries = "hd2";
	if ($chip_type == 33904 /*0x8470*/)
		$boxmodel = "shiner";
	else
		$boxmodel = "kronos";
}
elseif ($revision == 12)
{
	# CST - Zee²
	$boxtype_sc = "cst";
	$boxseries = "hd2";
	$boxmodel = "kronos";
}
elseif ($revision == 13 || $revision == 14)
{
	# CST - Link, Trinity Duo
	$boxtype_sc = "cst";
	$boxseries = "hd2";
	$boxmodel = "kronos_v2";
}

if (empty($image_type))
	$image_type = "nightly";

$directory = $image_type;

$result = "";
if (empty($boxtype_sc) || empty($boxseries) || empty($boxmodel))
{
	# fallback: send all files we have
	foreach (glob($directory . "/*.txt") as $file)
		$result .= file_get_contents($file, true);
	echo $result;
	exit(1);
}

$file = "release/release-" . $boxtype_sc . "-" . $boxmodel . ".txt";
if (file_exists($file))
	$result .= file_get_contents($file, true);

$file = "beta/beta-" . $boxtype_sc . "-" . $boxmodel . ".txt";
if (file_exists($file))
	$result .= file_get_contents($file, true);

$file = "nightly/nightly-" . $boxtype_sc . "-" . $boxmodel . ".txt";
if (file_exists($file))
	$result .= file_get_contents($file, true);

$file = $directory . "/update.txt";
if (file_exists($file))
	$result .= file_get_contents($file, true);

$file = $directory . "/update-" . $boxtype_sc . "-" . $boxseries . ".txt";
if (file_exists($file))
	$result .= file_get_contents($file, true);

$file = $directory . "/update-" . $boxtype_sc . "-" . $boxmodel . ".txt";
if (file_exists($file))
	$result .= file_get_contents($file, true);

#$file = "plugins/pr-auto-timer.txt";
#if (file_exists($file))
#	$result .= file_get_contents($file, true);

echo $result;
?>
