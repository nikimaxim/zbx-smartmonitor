<#
    .VERSION
    0.1

    .DESCRIPTION
    Author: Nikitin Maksim
    Github: https://github.com/nikimaxim/zbx-smartmonitor.git
    Note: Zabbix lld for smartctl

    .TESTING
    PowerShell: 5.1 and later
    Smartmontools: 7.1 and later
#>

$CTL = "C:\Program Files\smartmontools\bin\smartctl.exe"

if ((Get-Command $CTL -ErrorAction SilentlyContinue) -eq $null) {
    Write-Host "Not find smartctl!"
    exit
}

$idx = 0
$json = ""
$disk_sn_all = ""
$smart_scan = & $CTL "--scan-open"

Write-Host "{"
Write-Host " `"data`":["
foreach ($device in $smart_scan) {
    # Remove non-working disks
    # Example: "# /dev/sdb -d scsi"
    if (!$device.StartsWith("# ")) {
        $idx++
        $storage_args = ""
        $storage_name = ""
        $storage_type = 0
        $storage_model = ""
        $storage_sn = ""
        $storage_smart = 0

        if ($device -match '(-d) ([A-Za-z0-9/,\+]+)') {
            $storage_args = $matches[1] + $matches[2]
        }

        $storage_name = $device.Substring(0,$device.IndexOf(" "))
        $info = & $CTL "-i" $storage_name $storage_args

        # Device sn
        $sn = ($info | Select-String "serial number:") -ireplace "serial number:"

        # Сheck empty SN
        if ($sn) {
            $storage_sn = $sn.Trim()
            # Check duplicate storage
            if (!$disk_sn_all.Contains($storage_sn)) {
                if ($disk_sn_all) {
                    $disk_sn_all += "," + $storage_sn
                } else {
                    $disk_sn_all = $storage_sn
                }

                # Device smart
                if ($info | Select-String "SMART.+Enabled$") {
                    $storage_smart = 1
                }

                if ($storage_args -like "*nvme*" -or $storage_name -like "*nvme*") {
                    $storage_type = 1
                    $storage_smart = 1
                }

                # Device Model
                $d = (($info | Select-String "Device Model:") -replace "Device Model:")
                if ($d) {
                    $storage_model = $d.Trim()
                } else {
                    $p = (($info | Select-String "Product:") -replace "Product:")
                    if ($p) {
                        $storage_model = $p.Trim()
                    } else {
                        $v = (($info | Select-String "Vendor:") -replace "Vendor:")
                        if ($v) {
                            $storage_model = $v.Trim()
                        } else {
                            $storage_model = "Not find"
                        }
                    }
                }

                # 0 is for HDD
                # 1 is for SSD/NVMe
                $rotation_rate = $info | Select-String "Rotation Rate:"
                if ($rotation_rate -like "*rpm*") {
                    $storage_type = 0
                } elseif ($rotation_rate -like "*Solid State Device*") {
                    $storage_type = 1
                }

                if ($idx -ne 1) {
                    $json += ",`n"
                }

                $json += "`t {`n " +
                        "`t`t`"{#STORAGE.SN}`":`"" + $storage_sn + "`"" + ",`n" +
                        "`t`t`"{#STORAGE.MODEL}`":`"" + $storage_model + "`"" + ",`n" +
                        "`t`t`"{#STORAGE.NAME}`":`"" + $storage_name + "`"" + ",`n" +
                        "`t`t`"{#STORAGE.CMD}`":`"" + $storage_name + " " + $storage_args + "`"" + ",`n" +
                        "`t`t`"{#STORAGE.SMART}`":`"" + $storage_smart + "`"" + ",`n" +
                        "`t`t`"{#STORAGE.TYPE}`":`"" + $storage_type + "`"" + "`n" +
                        "`t }"
            }
        }
    }
}
Write-Host $json
Write-Host " ]"
Write-Host "}"
