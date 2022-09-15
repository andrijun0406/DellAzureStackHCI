# Written by Cosmos Darwin, PM
# Copyright (C) 2017 Microsoft Corporation
# MIT License
# 08/2017

Function ConvertTo-PrettyCapacity {
<#
.SYNOPSIS Convert raw bytes into prettier capacity strings.
.DESCRIPTION Takes an integer of bytes, converts to the largest unit (kilo-, mega-, giga-, tera-) that will result in at least 1.0, rounds to given precision, and appends standard unit symbol.
.PARAMETER Bytes The capacity in bytes.
.PARAMETER UseBaseTwo Switch to toggle use of binary units and prefixes (mebi, gibi) rather than standard (mega, giga).
.PARAMETER RoundTo The number of decimal places for rounding, after conversion.
#>

Param (
[Parameter(
Mandatory = $True,
ValueFromPipeline = $True
)
]
[Int64]$Bytes,
[Int64]$RoundTo = 0,
[Switch]$UseBaseTwo # Base-10 by Default
)

If ($Bytes -Gt 0) {
$BaseTenLabels = ("bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
$BaseTwoLabels = ("bytes", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB")
If ($UseBaseTwo) {
$Base = 1024
$Labels = $BaseTwoLabels
}
Else {
$Base = 1000
$Labels = $BaseTenLabels
}
$Order = [Math]::Floor( [Math]::Log($Bytes, $Base) )
$Rounded = [Math]::Round($Bytes/( [Math]::Pow($Base, $Order) ), $RoundTo)
[String]($Rounded) + $Labels[$Order]
}
Else {
0
}
Return
}


Function ConvertTo-PrettyPercentage {
<#
.SYNOPSIS Convert (numerator, denominator) into prettier percentage strings.
.DESCRIPTION Takes two integers, divides the former by the latter, multiplies by 100, rounds to given precision, and appends "%".
.PARAMETER Numerator Really?
.PARAMETER Denominator C'mon.
.PARAMETER RoundTo The number of decimal places for rounding.
#>

Param (
[Parameter(Mandatory = $True)]
[Int64]$Numerator,
[Parameter(Mandatory = $True)]
[Int64]$Denominator,
[Int64]$RoundTo = 1
)

If ($Denominator -Ne 0) { # Cannot Divide by Zero
$Fraction = $Numerator/$Denominator
$Percentage = $Fraction * 100
$Rounded = [Math]::Round($Percentage, $RoundTo)
[String]($Rounded) + "%"
}
Else {
0
}
Return
}

Function Find-LongestCommonPrefix {
<#
.SYNOPSIS Find the longest prefix common to all strings in an array.
.DESCRIPTION Given an array of strings (e.g. "Seattle", "Seahawks", and "Season"), returns the longest starting substring ("Sea") which is common to all the strings in the array. Not case sensitive.
.PARAMETER Strings The input array of strings.
#>

Param (
[Parameter(
Mandatory = $True
)
]
[Array]$Array
)

If ($Array.Length -Gt 0) {

$Exemplar = $Array[0]

$PrefixEndsAt = $Exemplar.Length # Initialize
0..$Exemplar.Length | ForEach {
$Character = $Exemplar[$_]
ForEach ($String in $Array) {
If ($String[$_] -Eq $Character) {
# Match
}
Else {
$PrefixEndsAt = [Math]::Min($_, $PrefixEndsAt)
}
}
}
# Prefix
$Exemplar.SubString(0, $PrefixEndsAt)
}
Else {
# None
}
Return
}

Function Reverse-String {
<#
.SYNOPSIS Takes an input string ("Gates") and returns the character-by-character reversal ("setaG").
#>

Param (
[Parameter(
Mandatory = $True,
ValueFromPipeline = $True
)
]
$String
)

$Array = $String.ToCharArray()
[Array]::Reverse($Array)
-Join($Array)
Return
}

Function New-UniqueRootLookup {
<#
.SYNOPSIS Creates hash table that maps strings, particularly server names of the form [CommonPrefix][Root][CommonSuffix], to their unique Root.
.DESCRIPTION For example, given ("Server-A2.Contoso.Local", "Server-B4.Contoso.Local", "Server-C6.Contoso.Local"), returns key-value pairs:
{
"Server-A2.Contoso.Local" -> "A2"
"Server-B4.Contoso.Local" -> "B4"
"Server-C6.Contoso.Local" -> "C6"
}
.PARAMETER Strings The keys of the hash table.
#>

Param (
[Parameter(
Mandatory = $True
)
]
[Array]$Strings
)

# Find Prefix

$CommonPrefix = Find-LongestCommonPrefix $Strings

# Find Suffix

$ReversedArray = @()
ForEach($String in $Strings) {
$ReversedString = $String | Reverse-String
$ReversedArray += $ReversedString
}

$CommonSuffix = $(Find-LongestCommonPrefix $ReversedArray) | Reverse-String

# String -> Root Lookup

$Lookup = @{}
ForEach($String in $Strings) {
$Lookup[$String] = $String.Substring($CommonPrefix.Length, $String.Length - $CommonPrefix.Length - $CommonSuffix.Length)
}

$Lookup
Return
}

### SCRIPT... ###

$Nodes = Get-StorageSubSystem Cluster* | Get-StorageNode
$Drives = Get-StoragePool S2D* | Get-PhysicalDisk

$Names = @()
ForEach ($Node in $Nodes) {
$Names += $Node.Name
}

$UniqueRootLookup = New-UniqueRootLookup $Names

$Output = @()

ForEach ($Drive in $Drives) {

If ($Drive.BusType -Eq "NVMe") {
$SerialNumber = $Drive.AdapterSerialNumber
$Type = $Drive.BusType
}
Else { # SATA, SAS
$SerialNumber = $Drive.SerialNumber
$Type = $Drive.MediaType
}

If ($Drive.Usage -Eq "Journal") {
$Size = $Drive.Size | ConvertTo-PrettyCapacity
$Used = "-"
$Percent = "-"
}
Else {
$Size = $Drive.Size | ConvertTo-PrettyCapacity
$Used = $Drive.VirtualDiskFootprint | ConvertTo-PrettyCapacity
$Percent = ConvertTo-PrettyPercentage $Drive.VirtualDiskFootprint $Drive.Size
}

$NodeObj = $Drive | Get-StorageNode -PhysicallyConnected
If ($NodeObj -Ne $Null) {
$Node = $UniqueRootLookup[$NodeObj.Name]
}
Else {
$Node = "-"
}

# Pack

$Output += [PSCustomObject]@{
"SerialNumber" = $SerialNumber
"Type" = $Type
"Node" = $Node
"Size" = $Size
"Used" = $Used
"Percent" = $Percent
}
}

$Output | Sort Used, Node | FT
