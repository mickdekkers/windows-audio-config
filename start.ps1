Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;

public struct RECT
{
    public int left;
    public int top;
    public int right;
    public int bottom;
}

public class pInvoke
{
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall, ExactSpelling = true, SetLastError = true)]
    public static extern bool GetWindowRect(IntPtr hWnd, ref RECT rect);
}
"@

# Uncomment this to see debug logging:
$DebugPreference = 'Continue'

# based on https://stackoverflow.com/a/41891599/1233003
function Move-Window([System.IntPtr]$WindowHandle, [int]$PosX, [int]$PosY) {
  # get the window bounds
  $rect = New-Object RECT;
  [pInvoke]::GetWindowRect($WindowHandle, [ref]$rect);

  # get which screen the app has been spawned into
#   $activeScreen = [System.Windows.Forms.Screen]::FromHandle($WindowHandle).Bounds

  [pInvoke]::MoveWindow($WindowHandle, $PosX, $PosY, $rect.right - $rect.left, $rect.bottom - $rect.top, $true);
}

# Tries to fit the windows in a square (assumes windows are themselves square)
function CalcNumColumns([int]$NumWindows) {
    # x
    #
    # xx
    #
    # xxx
    #
    # xx
    # xx
    #
    # xxx
    # xx
    #
    # xxx
    # xxx
    #
    # xxxx
    # xxx
    #
    # xxxx
    # xxxx
    #
    # xxx
    # xxx
    # xxx
    #
    # etc.
    return [int][Math]::Floor($NumWindows / [Math]::Sqrt($NumWindows));
}

$apps = @{};

Get-ChildItem "$pwd\configs" -Filter *.cfg | ForEach-Object {
    # TODO: avoid hardcoding this path
    $ar_exe = "C:\Program Files\Virtual Audio Cable\audiorepeater.exe";
    $cfg_path = "configs/" + $_.Name;

    # spawn the window and store the window object
    $app = Start-Process -FilePath $ar_exe -ArgumentList "/Config:`"$cfg_path`"" -Passthru;
    # -WindowStyle Minimized
    $apps[$app.Id] = $app
};

# We can only move each application's window when it's done loading, so we wait for that here
do {
    $done = [System.Collections.Generic.List[int]]::new();
    $apps.Values | Foreach-Object {
        $app = $_;
        # Check whether the app's window is ready yet
        # based on https://stackoverflow.com/a/35184224/1233003
        if ($app.MainWindowHandle -ne 0)
        {
            # Window is ready to be moved
            Write-Debug "Window ready: $($app.Id)"
            Move-Window -WindowHandle $app.MainWindowHandle -PosX 20 -PosY 200;
            $done.Add($app.Id);
        } else {
            # Window is not yet ready, refresh the process data for the next time we check
            $app.Refresh();
        }
    }
    # Remove the ones we're done with from $apps so we don't process them again
    $done | ForEach-Object {
        $apps.Remove($_);
    }
    Write-Debug "Remaining apps count is now: $($apps.count)"
    # Wait for a bit before checking the remaining apps again
    Start-Sleep -Milliseconds 250;
} while ($apps.count -gt 0)
