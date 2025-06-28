Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the Form
$form = New-Object Windows.Forms.Form
$form.Text = "JD1738's Windows Repair Utility"
$form.Size = New-Object Drawing.Size(520, 380)
$form.StartPosition = "CenterScreen"

# Header Description
$descLabel = New-Object Windows.Forms.Label
$descLabel.Text = "🛠 This tool repairs Windows using DISM and SFC."
$descLabel.Text = "WARNING! FOR BEST EFFECT, DO NOT USE YOUR COMPUTER WHILE THEY ARE BOTH RUNNING!"
$descLabel.Text = "Thank-You for using my Utility. Check out my Github! github.com/JD1738"
$descLabel.Location = New-Object Drawing.Point(10, 10)
$descLabel.Size = New-Object Drawing.Size(480, 20)
$form.Controls.Add($descLabel)

# DISM Description
$dismDesc = New-Object Windows.Forms.Label
$dismDesc.Text = "Step 1: DISM repairs the Windows image that SFC depends on."
$dismDesc.Location = New-Object Drawing.Point(10, 40)
$dismDesc.Size = New-Object Drawing.Size(480, 30)
$form.Controls.Add($dismDesc)

# SFC Description
$sfcDesc = New-Object Windows.Forms.Label
$sfcDesc.Text = "Step 2: SFC scans and repairs system files using the repaired image."
$sfcDesc.Location = New-Object Drawing.Point(10, 70)
$sfcDesc.Size = New-Object Drawing.Size(480, 30)
$form.Controls.Add($sfcDesc)

# Status Label
$statusLabel = New-Object Windows.Forms.Label
$statusLabel.Text = "Status: Please start with DISM."
$statusLabel.Location = New-Object Drawing.Point(10, 260)
$statusLabel.Size = New-Object Drawing.Size(480, 30)
$form.Controls.Add($statusLabel)

# Final Message Label
$finalLabel = New-Object Windows.Forms.Label
$finalLabel.Text = "✅ Congratulations! Restart your PC for optimal effect."
$finalLabel.Location = New-Object Drawing.Point(10, 290)
$finalLabel.Size = New-Object Drawing.Size(480, 30)
$finalLabel.ForeColor = "Green"
$finalLabel.Visible = $false
$form.Controls.Add($finalLabel)

# DISM Button
$dismButton = New-Object Windows.Forms.Button
$dismButton.Text = "▶ Run DISM /RestoreHealth"
$dismButton.Location = New-Object Drawing.Point(40, 120)
$dismButton.Size = New-Object Drawing.Size(200, 40)
$form.Controls.Add($dismButton)

# SFC Button
$sfcButton = New-Object Windows.Forms.Button
$sfcButton.Text = "▶ Run SFC /scannow"
$sfcButton.Location = New-Object Drawing.Point(260, 120)
$sfcButton.Size = New-Object Drawing.Size(200, 40)
$sfcButton.Enabled = $false
$form.Controls.Add($sfcButton)

# Helper: Show error popup
function Show-CriticalError {
    param ($title, $message)
    [System.Windows.Forms.MessageBox]::Show($message, $title, 'OK', 'Error')
}

# DISM Click Event
$dismButton.Add_Click({
    $statusLabel.Text = "Status: Running DISM..."
    $form.Refresh()

    $dismProcess = Start-Process -FilePath "DISM.exe" `
        -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" `
        -Wait -PassThru -NoNewWindow

    if ($dismProcess.ExitCode -eq 0) {
        $statusLabel.Text = "DISM completed. You can now run SFC."
        $sfcButton.Enabled = $true
    } else {
        $statusLabel.Text = "DISM failed. Cannot continue."
        Show-CriticalError -title "DISM Error" -message "DISM failed (Exit Code: $($dismProcess.ExitCode)). Please restart your PC and try again."
    }
})

# SFC Click Event
$sfcButton.Add_Click({
    $statusLabel.Text = "Status: Running SFC..."
    $form.Refresh()

    $sfcProcess = Start-Process -FilePath "sfc.exe" `
        -ArgumentList "/scannow" -Wait -PassThru -NoNewWindow

    if ($sfcProcess.ExitCode -eq 0) {
        $statusLabel.Text = "SFC completed successfully."
        $finalLabel.Visible = $true
    } else {
        $statusLabel.Text = "SFC encountered issues."
        Show-CriticalError -title "SFC Error" -message "SFC failed (Exit Code: $($sfcProcess.ExitCode)). Please restart your PC and try again."
    }
})

# Show the form
[void]$form.ShowDialog()