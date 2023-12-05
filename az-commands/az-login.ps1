. .\general.ps1

# $u = "odl_user_1140108@simplilearnhol42.onmicrosoft.com"
# $p = "jcqj63EBR*HY" 

Write-Output "[Login] Starting"

# check all parameters
$rArgs = @($args[0], "Azure username", $true), @($args[1], "Azure password", $true)
$rArgs = processArgs -rArgs $rArgs
if ($rArgs -eq $false) { 
    "Missing required variables, exiting"
    exit 
}
$u, $p = $rArgs
$usr, $pss = $u[0], $p[0]

# check if already logged in
$account = az account show
if ((hasL -var $account) -eq $false) { $account = $false }


# Check if account is logged in and correct account
$login = $true
if ($account -eq $true) {
    $json = $account | ConvertFrom-Json
    if ($json.user.name -eq $usr) {
        Write-Output "Already logged in: $usr"
        $login = $false
    } else {
        Write-Output "Different account logged in"
        Write-Output "Logging out other account"
        $result = logoutFromAzure -u $usr
        $login = $true
    }
}

# Login user if required
if ($login -eq $true) {
    Write-Output "Not logged in"
    Write-Output "Logging into account: $usr"
    loginToAzure -u $usr -p $pss
}

Write-Output "[Login] Finishing"
