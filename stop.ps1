Get-ChildItem "$pwd\configs" -Filter *.cfg | ForEach-Object {
    $window_name = $_.Name.Substring(0, $_.Name.Length - 4);

    # TODO: make this more reliable. Doesn't seem to close error dialogs, not sure if it closes the audiorepeaters that are displaying those
    # TODO: avoid hardcoding this path
    Start-Process -FilePath "C:\Program Files\Virtual Audio Cable\audiorepeater.exe" -ArgumentList "/CloseInstance:`"$window_name`"" -WindowStyle Minimized;
};
