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

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
}
"@

# Uncomment this to see debug logging:
# $DebugPreference = 'Continue'

function MinimizeWindow([System.IntPtr]$WindowHandle) {
    # 6 is SW_MINIMIZE
    # https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
    [pInvoke]::ShowWindowAsync($WindowHandle, 6) | Out-Null;
}

# based on https://stackoverflow.com/a/41891599/1233003
function MoveWindow([System.IntPtr]$WindowHandle, [int]$PosX, [int]$PosY) {
  # get the window bounds
  $rect = New-Object RECT;
  [pInvoke]::GetWindowRect($WindowHandle, [ref]$rect) | Out-Null;

  [pInvoke]::MoveWindow($WindowHandle, $PosX, $PosY, $rect.right - $rect.left, $rect.bottom - $rect.top, $true) | Out-Null;
}

# Assumes all windows are the same dimensions
function MoveWindowInGrid([System.IntPtr]$WindowHandle, [int]$NumWindows, [int]$WindowIndex) {
    # get the window bounds
    $rect = New-Object RECT;
    [pInvoke]::GetWindowRect($WindowHandle, [ref]$rect) | Out-Null;
    $windowWidth = $rect.right - $rect.left;
    $windowHeight = $rect.bottom - $rect.top

    $numRows = CalcNumRows($NumWindows);
    $windowsPerRow = [Math]::Ceiling($NumWindows / $numRows);
    $columnIndex = $WindowIndex % $windowsPerRow;
    $rowIndex = [Math]::Floor($WindowIndex / $windowsPerRow);
    $posX = $columnIndex * $windowWidth;
    $posY = $rowIndex * $windowHeight;


    # get which screen the app has been spawned into
    # $activeScreen = [System.Windows.Forms.Screen]::FromHandle($WindowHandle).Bounds

    MoveWindow -WindowHandle $WindowHandle -PosX $posX -PosY $posY
}

# Tries to fit the windows in a square (assumes windows are themselves square)
function CalcNumRows([int]$NumWindows) {
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

$numWindows = $apps.count;
$windowIndex = 0;
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
            Write-Debug "Window index: $($windowIndex)"
            # TODO: use deterministic index based on config name
            MoveWindowInGrid -WindowHandle $app.MainWindowHandle -NumWindows $numWindows -WindowIndex $windowIndex
            MinimizeWindow -WindowHandle $app.MainWindowHandle
            $windowIndex++;
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
