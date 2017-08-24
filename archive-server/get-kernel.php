<?php
/*
	Example:
	http://www.neutrino-images.de/neutrino-images/get-kernel.php?boxtype=coolstream&boxmodel=kronos
*/

$boxtype = trim($_GET["boxtype"]);
$boxtype_sc = ""; # autofilled
$boxseries = trim($_GET["boxseries"]);
$boxmodel = trim($_GET["boxmodel"]);

$kernel_name = "";
$image_type = "release";

# convert strings to lower case
$boxtype = strtolower($boxtype);
$boxtype_sc = strtolower($boxtype_sc);
$boxseries = strtolower($boxseries);
$boxmodel = strtolower($boxmodel);
$image_type = strtolower($image_type);

if ($boxtype == "coolstream" || $boxtype == "cst")
{
	# CST
	$boxtype_sc = "cst";

	if ($boxmodel == "nevis")
	{
		$kernel_name = "zImage.img";
	}
	elseif ($boxmodel == "apollo" || $boxmodel == "shiner" || $boxmodel == "kronos" || $boxmodel == "kronos_v2")
	{
		$kernel_name = "vmlinux.ub.gz";
	}
}

# release/kernel-cst-kronos-vmlinux.ub.gz
$directory = $image_type;
$kernel = $directory . "/kernel-" . $boxtype_sc . "-" . $boxmodel . "-" . $kernel_name;

if (!file_exists($kernel))
{
	# send error
	header('HTTP/1.0 404 Not Found');
	die("<h1>404</h1>\nKernel not found.");
}
else
{
	# send kernel
	header("Content-Type: application/octet-stream");
	header("Content-Disposition: attachment; filename=\"$kernel\"");
	readfile($kernel);
}
?>