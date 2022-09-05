<?php
/*
	Example:
	http://www.neutrino-images.de/neutrino-images/get-kernel.php?boxtype=coolstream&boxmodel=apollo
*/

$boxtype = trim($_GET["boxtype"]);
$boxtype_sc = ""; # autofilled
$boxseries = trim($_GET["boxseries"]);
$boxmodel = trim($_GET["boxmodel"]);

$kernel_suffix = "";
$image_version = "???"; # wildcard for version (e.g. 320)
$image_date = "????????????"; # wildcard for date (e.g. 201601012359)
$image_type = "nightly";

# convert strings to lower case
$boxtype = strtolower($boxtype);
$boxtype_sc = strtolower($boxtype_sc);
$boxseries = strtolower($boxseries);
$boxmodel = strtolower($boxmodel);
$image_type = strtolower($image_type);

if ($boxtype == "coolstream" || $boxtype == "cst")
{
	$boxtype_sc = "cst";

	if ($boxmodel == "nevis")
	{
		$kernel_suffix = "-zImage.img";
	}
	elseif ($boxmodel == "apollo" || $boxmodel == "shiner" || $boxmodel == "kronos" || $boxmodel == "kronos_v2")
	{
		$kernel_suffix = "-vmlinux.ub.gz";
	}
}
elseif ($boxtype == "armbox" || $boxtype == "arm")
{
	$boxtype_sc = "arm";

	$kernel_suffix = ".bin";
}

# release/ni320-YYYYMMDDHHMM-cst-kronos-vmlinux.ub.gz
$directory = $image_type;
$pattern = $directory . "/ni" . $image_version . "-" . $image_date . "-" . $boxtype_sc . "-" . $boxmodel . $kernel_suffix;

# find last (newest) kernel
$last_mod = 0;
$last_kernel = "";
foreach (glob($pattern) as $kernel)
{
	if (is_file($kernel) && filectime($kernel) > $last_mod)
	{
		$last_mod = filectime($kernel);
		$last_kernel = $kernel;
	}
}

if (empty($last_kernel))
{
	# send error
	header('HTTP/1.0 404 Not Found');
	die("<h1>404</h1>\nKernel not found.");
}
else
{
	# send kernel
	header('Content-Description: File Transfer');
	header('Content-Type: application/octet-stream');
	header('Content-Disposition: attachment; filename="' . basename($last_kernel) . '"');
	header('Expires: 0');
	header('Cache-Control: must-revalidate');
	header('Pragma: public');
	header('Content-Length: ' . filesize($last_kernel));
	readfile($last_kernel);
}
?>