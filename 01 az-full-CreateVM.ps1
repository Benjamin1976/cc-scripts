
$u = "odl_user_1128706@simplilearnhol53.onmicrosoft.com"
$p = "borh44EMB*Wu" 

$rg="bens-rg2"
$location = "East US"

$vmUsr = "benjamin"
$vmPass = "benjamin_123"
$dnsPrefix = "bens-vm-win-"


.\az-commands\az-login.ps1 $u $p
.\az-commands\az-rg-check.ps1 $rg $location
.\az-commands\createVm.ps1 $rg, $location, $vmUsr, $vmPass, $dnsPrefix