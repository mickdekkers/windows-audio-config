Get-ChildItem "$pwd\configs" -Filter *.cfg | ForEach-Object {
    # TODO: avoid hardcoding these paths
    $ar_exe = If ($_.Name.StartsWith("[AR KS]")) {
        "C:\Program Files\Virtual Audio Cable\audiorepeater_ks.exe"
    } Else {
        "C:\Program Files\Virtual Audio Cable\audiorepeater.exe"
    };
    $cfg_path = "configs/" + $_.Name;

    Start-Process -FilePath $ar_exe -ArgumentList "/Config:`"$cfg_path`"" -WindowStyle Minimized;
};
