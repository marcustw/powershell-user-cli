$Form1 = New-Object -TypeName System.Windows.Forms.Form
function InitializeComponent
{
$Form1.SuspendLayout()
#
#Form1
#
$Form1.Text = [System.String]'Form1'
$Form1.add_Load($Form1_Load)
$Form1.ResumeLayout($false)
Add-Member -InputObject $Form1 -Name base -Value $base -MemberType NoteProperty
}
. InitializeComponent
