Get-ChildItem "$pwd\configs" -Filter *.cfg | ForEach-Object {
    $window_name = $_.Name.Substring(0, $_.Name.Length - 4);

    # TODO: avoid hardcoding this path
    Start-Process -FilePath "C:\Program Files\Virtual Audio Cable\audiorepeater.exe" -ArgumentList "/CloseInstance:`"$window_name`"" -WindowStyle Minimized;
};
