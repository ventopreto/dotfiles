#!/usr/bin/env bash
set -euo pipefail

# Consume stdin (Claude Code sends JSON event data)
cat > /dev/null || true

# Detect focus: get foreground window title via PowerShell
# If Zellij is in the foreground, suppress the notification
WINDOW_TITLE=$(powershell.exe -NoProfile -NonInteractive -Command '
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Win32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder sb, int n);
  }
"@
$hwnd = [Win32]::GetForegroundWindow()
$sb = New-Object System.Text.StringBuilder 256
[Win32]::GetWindowText($hwnd, $sb, 256) | Out-Null
$sb.ToString()
' 2>/dev/null | tr -d '\r' || echo "")

if echo "$WINDOW_TITLE" | grep -qi "zellij"; then
  exit 0
fi

# Fire Windows toast notification in background
powershell.exe -NoProfile -NonInteractive -WindowStyle Hidden -Command '
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
$t = [Windows.UI.Notifications.ToastTemplateType]::ToastText01
$xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($t)
$node = $xml.SelectSingleNode("//text[@id='"'"'1'"'"']")
$textNode = $xml.CreateTextNode("Claude is waiting for input")
$node.AppendChild($textNode) | Out-Null
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code")
$notifier.Show([Windows.UI.Notifications.ToastNotification]::new($xml))
' 2>>/tmp/claude-toast-err.log &

exit 0
