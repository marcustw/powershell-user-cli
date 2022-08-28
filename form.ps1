# Run as Administrator
param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

$CREATED_USER_MESSAGE = "Created by Marcus PowerShell App"

$Form1_Load = {
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Marcus PowerShell Application'
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = 'CenterScreen'

$enterNameLabel = New-Object System.Windows.Forms.Label
$enterNameLabel.Location = New-Object System.Drawing.Point(100,40)
$enterNameLabel.Size = New-Object System.Drawing.Size(300,20)
$enterNameLabel.Text = 'Enter name:'
$form.Controls.Add($enterNameLabel)

$nameBox = New-Object System.Windows.Forms.TextBox
$nameBox.Location = New-Object System.Drawing.Point(100,60)
$nameBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($nameBox)

$newNameLabel = New-Object System.Windows.Forms.Label
$newNameLabel.Location = New-Object System.Drawing.Point(100,100)
$newNameLabel.Size = New-Object System.Drawing.Size(300,20)
$newNameLabel.Text = 'Enter new name:'
$form.Controls.Add($newNameLabel)

$newNameBox = New-Object System.Windows.Forms.TextBox
$newNameBox.Location = New-Object System.Drawing.Point(100,120)
$newNameBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($newNameBox)

Function get_local_users
{
    $localUsers = Get-WmiObject -Class Win32_UserAccount -filter "Description='$($CREATED_USER_MESSAGE)'" | Select name
    return $localUsers
}

Function get_local_users_string
{
    $localUsers = get_local_users
    $result = ""
    foreach ($usr in $localUsers) {
        $result += $usr.name + ", "
    }
    if ($result.length -gt 0) {
        $result = $result.substring(0, $result.length - 2)
    }
    return $result
}

Function wrong_name_msg
{
    [System.Windows.MessageBox]::Show('Eh help lah, name not found la dey! Enter a correct name.','Error','Ok','Error')
}

Function check_input_name
{
    if ($nameBox.TextLength -eq 0) {
        [System.Windows.MessageBox]::Show('Eh help lah, please enter a name before you click a button','Error','Ok','Error')
        return $false
    }
    return $true
}

Function refresh_list
{
    $namesLabel.text = get_local_users_string
}

# Create local user
$Create_Click =
{
    if (check_input_name -eq $true) {
        New-LocalUser -name $nameBox.text -Description $CREATED_USER_MESSAGE -NoPassword
        write-host "Done creating user $($nameBox.text)"
    } else {
        wrong_name_msg
    }
    refresh_list
}

# Delete local user
$Delete_Click = 
{
    if (check_input_name -eq $true) {
        $localUsers = get_local_users

        if ($localUsers.name -contains $nameBox.text) {
            Remove-LocalUser -name $nameBox.text
            write-host "Done deleting user $($nameBox.text)"
        } else {
            wrong_name_msg
            write-host "Unable to delete user $($nameBox.text)"
        }
    }
    refresh_list
}

$Rename_Click =
{
    if (check_input_name -eq $true) {
        $localUsers = get_local_users

        if ($localUsers.name -contains $nameBox.text) {
            Rename-LocalUser -name $nameBox.text -NewName $newNameBox.text
            write-host "Done renaming user $($nameBox.text) to $($newNameBox.text)"
        } else {
            wrong_name_msg
            write-host "Unable to rename user $($nameBox.text)"
        }
    }
    refresh_list
}

$createButton = New-Object System.Windows.Forms.Button
$createButton.Location = New-Object System.Drawing.Point(125,300)
$createButton.Size = New-Object System.Drawing.Size(75,23)
$createButton.Text = 'Create'
$createButton.Add_Click($Create_Click)
$form.Controls.Add($createButton)

$deleteButton = New-Object System.Windows.Forms.Button
$deleteButton.Location = New-Object System.Drawing.Point(300,300)
$deleteButton.Size = New-Object System.Drawing.Size(75,23)
$deleteButton.Text = 'Delete'
$deleteButton.Add_Click($Delete_Click)
$form.Controls.Add($deleteButton)

$renameButton = New-Object System.Windows.Forms.Button
$renameButton.Location = New-Object System.Drawing.Point(200,150)
$renameButton.Size = New-Object System.Drawing.Size(75,23)
$renameButton.Text = 'Rename'
$renameButton.Add_Click($Rename_Click)
$form.Controls.Add($renameButton)

$createdLabel = New-Object System.Windows.Forms.Label
$createdLabel.Location = New-Object System.Drawing.Point(200,200)
$createdLabel.Size = New-Object System.Drawing.Size(300,20)
$createdLabel.Text = "Created Users:"
$form.Controls.Add($createdLabel)

$namesLabel = New-Object System.Windows.Forms.Label
$namesLabel.Location = New-Object System.Drawing.Point(75,220)
$namesLabel.Size = New-Object System.Drawing.Size(450,50)
$namesLabel.Text = get_local_users_string
$form.Controls.Add($namesLabel)


$form.Topmost = $true

$form.Add_Shown({$nameBox.Select()})
$result = $form.ShowDialog()

