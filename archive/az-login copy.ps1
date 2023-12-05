$u = "odl_user_1128706@simplilearnhol53.onmicrosoft.com"
$p = "borh44EMB*Wu"

$sb = Start-Job -ScriptBlock{
    $account = az account show
    $json = $account | ConvertFrom-Json
    Write-Output "hello"
    <# $i = 0
    while($i -lt 10){
    $i++
    Sleep 3
    }#>
    #Az login
    #$user = "az account show"
    #Write-Output "----"
    #Write-Output $user
    #Write-Output "----"
    #az login
    #az login -u johndoe@contoso.com -p VerySecret
}
Write-Output "--starting--"
$account = az account show
$json = $account | ConvertFrom-Json
$loggedin = $json.user.name -eq $u


Write-Output "User logged in: $loggedin"
Wait-Job $sb.Name
Write-Output "--finshing--"
Write-Output "This line will be executed after job completes"