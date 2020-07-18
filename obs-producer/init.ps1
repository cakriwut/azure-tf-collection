param (
    $interactive = $false
)

$baseTemp = "C:\temp"
if( !(Test-Path $baseTemp)) {
  mkdir $baseTemp
}

# Other packages
function Output-Folder {
    param (
        [string] $fileUrl
     )
  
     return Join-Path $baseTemp (Split-Path $fileUrl -Leaf)
}

if($interactive -eq $false) {

    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    $chocoPackages = 'skype','obs-studio','obs-ndi','git'

    foreach($pkg in $chocoPackages){
        Start-Job -ScriptBlock { choco install $args[0] -y } -ArgumentList $pkg 
    }

    $source = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
    $target = Output-Folder -fileUrl $source
        Invoke-WebRequest $source -OutFile $target -UseBasicParsing
        $arguments = "/quiet /install /log $target.log"
        $cmd = "$target $arguments"
        #Invoke-Expression($cmd)
        Start-Process $target -ArgumentList $arguments -Wait 


        $source = "https://github.com/ykhwong/ppt-ndi/releases/download/1.0.4/pptndi_setup.exe"
        $target = Output-Folder -fileUrl $source
        Invoke-WebRequest $source -OutFile $target -UseBasicParsing
        $arguments = "/silent /allusers /log $target.log"
        $cmd = "$target $arguments"
        #Invoke-Expression($cmd)
        Start-Process $target -ArgumentList $arguments -Wait 
    
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

    Get-Job | Wait-Job

} else {
            
    $source = "https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack43.zip"
    $target = Output-Folder -fileUrl $source
    Invoke-WebRequest $source -OutFile $target -UseBasicParsing
    Expand-Archive $target -DestinationPath $target.Replace(".zip","") -Force
    $cmd = Join-Path ($target.Replace(".zip","")) "VBCABLE_Setup_x64.exe "
    Invoke-Expression($cmd)       

    Start-Process https://github.com/cakriwut/azure-tf-collection/blob/master/README.md

    choco install microsoft-teams -y   

    
    #$result = Invoke-WebRequest http://mkto-q0143.com/gn0Uraf0s30qVC0MQ000t6c -UseBasicParsing
    $webclient = new-object System.Net.WebClient
    $resultText = $webclient.DownloadString("http://mkto-q0143.com/gn0Uraf0s30qVC0MQ000t6c")

    $startUrl = $resultText.IndexOf('http');
    $endUrl = $resultText.IndexOf("';",$startUrl);
    $dynamicFileurl = $resultText.SubString($startUrl,$endUrl-$startUrl)
    $target = Output-Folder -fileUrl "NdiTools.exe"
    Invoke-WebRequest $dynamicFileurl -OutFile $target -UseBasicParsing
    $arguments = "/verysilent /supressmsgboxes /log=$target.log" 
    $cmd = "$target $arguments"    
    #Invoke-Expression($cmd)        
    Start-Process $target -ArgumentList $arguments -Wait   
   
    $source = "https://aka.ms/wsl-ubuntu-1804"
    $target = "$(Output-Folder -fileUrl $source).appx"
    Invoke-WebRequest $source -OutFile $target -UseBasicParsing
    Add-AppxPackage -Path $target    
    
}