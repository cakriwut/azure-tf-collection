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
        Invoke-Command -ScriptBlock { choco install $args[0] -y } -ArgumentList $pkg
    }

    $source = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
    $target = Output-Folder -fileUrl $source
    Invoke-WebRequest $source -OutFile $target
    $cmd = "$target /quiet /install /log $target.log"
    Invoke-Expression($cmd)


    $source = "https://github.com/ykhwong/ppt-ndi/releases/download/1.0.4/pptndi_setup.exe"
    $target = Output-Folder -fileUrl $source
    Invoke-WebRequest $source -OutFile $target
    $cmd = "$target /silent /allusers /log $target.log"
    Invoke-Expression($cmd)

    $response = Invoke-WebRequest http://mkto-q0143.com/gn0Uraf0s30qVC0MQ000t6c
    $startUrl = $response.RawContent.IndexOf('http');
    $endUrl = $response.RawContent.IndexOf("';",$startUrl);
    $dynamicFileurl = $response.RawContent.SubString($startUrl,$endUrl-$startUrl)
    $target = Output-Folder -fileUrl "NdiTools.exe"
    Invoke-WebRequest $dynamicFileurl -OutFile $target
    $cmd = "$target /silent /log=$target.log"
    Invoke-Expression($cmd) 

} else {
    
    & choco --% install microsoft-teams -y

    $source = "https://download.vb-audio.com/Download_CABLE/VBCABLE_Driver_Pack43.zip"
    $target = Output-Folder -fileUrl $source
    Invoke-WebRequest $source -OutFile $target
    Expand-Archive $target -DestinationPath $target.Replace(".zip","") -Force
    $cmd = Join-Path ($target.Replace(".zip","")) "VBCABLE_Setup_x64.exe "
    Invoke-Expression($cmd)

}