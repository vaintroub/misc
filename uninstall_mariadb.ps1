param (
    [switch]$x64 = $false
)

$pattern = "MariaDB *.*";
$reghive = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*";
$logfile = $Env:TEMP + "\\mariadb_uninstall.log";

if ($x64)
{
    $pattern = "MariaDB *.* (x64)";
    $reghive = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*";
    $logfile = $Env:TEMP + "\\mariadb_x64_uninstall.log";
}

$installed = Get-ItemProperty $reghive  | where DisplayName -Like $pattern;
$guid_to_productname=@{};

# Extract GUID from UninstallString 
Foreach ($product in $installed)
{
  $guid = $product.UninstallString -replace '.*{','';
  $guid = $guid -replace '}','';
  $guid_to_productname[$guid]=$product.DisplayName + ", version " + $product.DisplayVersion;
}

foreach($guid in $guid_to_productname.keys)
{
   write-host "uninstalling '" $guid_to_productname[$guid]  "' (" $guid ")";
   $process = Start-Process msiexec.exe -ArgumentList /x, "{$guid}" , /qn, /lv, $logfile -Wait -PassThru;
   if ($process.ExitCode -ne 0)
   {
     write-host "Error " $process.ExitCode " from msiexec";
     write-host "dumping " $logfile;
     cat $logfile;
   }
}

