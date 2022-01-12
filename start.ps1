Get-ChildItem "$pwd\configs" -Filter *.cfg | ForEach-Object {
    # TODO: avoid hardcoding this path
    $ar_exe = "C:\Program Files\Virtual Audio Cable\audiorepeater.exe";
    $cfg_path = "configs/" + $_.Name;

    Start-Process -FilePath $ar_exe -ArgumentList "/Config:`"$cfg_path`"" -WindowStyle Minimized;
};
