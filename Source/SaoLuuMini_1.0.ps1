# Add-Type để gọi chức năng move thùng rác.
Add-Type -AssemblyName Microsoft.VisualBasic

function Group_WPF {
    param (
        [Windows.Controls.Canvas]$canvas,
        [bool]$more,
        [ref]$ongr,
        [int]$top,
        [ref]$f1,
        [string]$n1,
        [ref]$f2,
        [string]$n2,
        [ref]$isR,
        [ref]$isB,
        [ref]$bu,
        [bool]$color1
    )

    $ongr.Value = New-Object Windows.Controls.CheckBox
    $ongr.Value.Content = "Bật"
    [Windows.Controls.Canvas]::SetLeft($ongr.Value, 10)
    [Windows.Controls.Canvas]::SetTop($ongr.Value, $top + 5)
    [void]$canvas.Children.Add($ongr.Value)

    if ($more) {
		$left = [int]50
    } else {
		$left = [int]10
	}

    if ($color1) {
        $f1cl = 'LightCyan'
        $f2cl = 'LightYellow'
    } else {
        $f1cl = 'LavenderBlush'
        $f2cl = 'Lavender'
    }

    # Tạo và cấu hình Label và TextBox cho F1
    $t1 = New-Object Windows.Controls.Label
    $t1.Content = "$n1 Đường dẫn Nguồn cần được sao lưu"
    [Windows.Controls.Canvas]::SetLeft($t1, $left)
    [Windows.Controls.Canvas]::SetTop($t1, $top)
    [void]$canvas.Children.Add($t1)

    $f1.Value = New-Object Windows.Controls.TextBox
    $f1.Value.Width = 380
    [Windows.Controls.Canvas]::SetLeft($f1.Value, 10)
    [Windows.Controls.Canvas]::SetTop($f1.Value, $top + 25)
    $f1.Value.Background = [System.Windows.Media.Brushes]::$f1cl
    [void]$canvas.Children.Add($f1.Value)

    $f1.Value.Add_MouseDoubleClick({
        param ($source, $e)
        $source.SelectAll()
    })

    # Tạo và cấu hình Label và TextBox cho F2
    $t2 = New-Object Windows.Controls.Label
    $t2.Content = "$n2 Đường dẫn Thư mục Đích chứa bản sao"
    [Windows.Controls.Canvas]::SetRight($t2, 10)
    [Windows.Controls.Canvas]::SetTop($t2, $top)
    [void]$canvas.Children.Add($t2)

    $f2.Value = New-Object Windows.Controls.TextBox
    $f2.Value.Width = 380
    [Windows.Controls.Canvas]::SetRight($f2.Value, 10)
    [Windows.Controls.Canvas]::SetTop($f2.Value, $top + 25)
    $f2.Value.Background = [System.Windows.Media.Brushes]::$f2cl
    [void]$canvas.Children.Add($f2.Value)

    $f2.Value.Add_MouseDoubleClick({
        param ($source, $e)
        $source.SelectAll()
    })

    # Tạo và cấu hình Label và CheckBox cho các tùy chọn khác
    $t3 = New-Object Windows.Controls.Label
    $t3.Content = "Đưa tệp/thư mục $n2 khác $n1 vào"
    [Windows.Controls.Canvas]::SetLeft($t3, 10)
    [Windows.Controls.Canvas]::SetTop($t3, $top + 45)
    [void]$canvas.Children.Add($t3)

    $isR.Value = New-Object Windows.Controls.CheckBox
    $isR.Value.Content = "Thùng rác"
    $isR.Value.IsChecked = $true
    [Windows.Controls.Canvas]::SetLeft($isR.Value, 210)
    [Windows.Controls.Canvas]::SetTop($isR.Value, $top + 50)
    [void]$canvas.Children.Add($isR.Value)

    $isB.Value = New-Object Windows.Controls.CheckBox
    $isB.Value.Content = "Dự phòng tại"
    [Windows.Controls.Canvas]::SetLeft($isB.Value, 290)
    [Windows.Controls.Canvas]::SetTop($isB.Value, $top + 50)
    [void]$canvas.Children.Add($isB.Value)

    $bu.Value = New-Object Windows.Controls.TextBox
    $bu.Value.Width = 380
    $bu.Value.IsReadOnly = $true
    $bu.Value.Background = [System.Windows.Media.Brushes]::Gainsboro
    [Windows.Controls.Canvas]::SetRight($bu.Value, 10)
    [Windows.Controls.Canvas]::SetTop($bu.Value, $top + 50)
    [void]$canvas.Children.Add($bu.Value)

	if ($more) {
        $ongr.Value.Visibility = 'Visible'
        $f1.Value.IsEnabled = $false
        $f2.Value.IsEnabled = $false
        $isR.Value.IsEnabled = $false
        $isB.Value.IsEnabled = $false
        $bu.Value.IsEnabled = $false
    } else {
		$ongr.Value.Visibility = 'Hidden'
	}

    $bu.Value.Add_MouseDoubleClick({
		param ($source, $e)
        $source.SelectAll()
	})

	$isB.Value.Add_Checked({
		$bu.Value.IsReadOnly = $false
		$bu.Value.Background = [System.Windows.Media.Brushes]::White
		$isR.Value.IsChecked = $false
	}.GetNewClosure())

	$isB.Value.Add_Unchecked({
		$bu.Value.IsReadOnly = $true
		$bu.Value.Background = [System.Windows.Media.Brushes]::Gainsboro
	}.GetNewClosure())

	$isR.Value.Add_Checked({
		$isB.Value.IsChecked = $false
	}.GetNewClosure())
    
    $ongr.Value.Add_Checked({
        if ($more) {
            $f1.Value.IsEnabled = $true
            $f2.Value.IsEnabled = $true
            $isR.Value.IsEnabled = $true
            $isB.Value.IsEnabled = $true
            $bu.Value.IsEnabled = $true
        }
    }.GetNewClosure())

    $ongr.Value.Add_Unchecked({
        if ($more) {
            $f1.Value.IsEnabled = $false
            $f2.Value.IsEnabled = $false
            $isR.Value.IsEnabled = $false
            $isB.Value.IsEnabled = $false
            $bu.Value.IsEnabled = $false
        }
    }.GetNewClosure())
}

# Lấy RelativeName của mọi file và thư mục con bên trong.
function Get-RelativeNameFolder {
    param (
        [string]$Path
    )

    # Hàm con để lấy tên tương đối của từng file/thư mục
    function Get-RelativeName {
        param (
            [string]$itemPath,
            [bool]$isFile
        )

        $item = Get-Item -LiteralPath $itemPath -Force -EA 0

        if ($isFile) {
            $idString = "$($item.Length),$($item.CreationTime.ToString('yyyyMMddHHmmss')),$($item.LastWriteTime.ToString('yyyyMMddHHmmss')),$($item.Extension)"
        } else {
            $idString = "$($item.CreationTime.ToString('yyyyMMddHHmmss'))"
        }

        $relativePath = $itemPath.Substring($Path.Length).TrimStart('\')
        $parentPath = Split-Path -Parent $relativePath

        if ($parentPath -eq '') {
            $relativeName = $idString
        } else {
            $relativeName = Join-Path -Path $parentPath -ChildPath $idString
        }

        return $relativeName
    }

    # Lấy tất cả các file và thư mục trong thư mục gốc và các thư mục con
    if ((-not [string]::IsNullOrEmpty($Path)) -and (Test-Path $Path)) {
        $items = Get-ChildItem -LiteralPath $Path -Recurse -Force -EA 0
    }

    foreach ($item in $items) {
        $isFile = -not $item.PSIsContainer
        $relativeName = Get-RelativeName -itemPath $item.FullName -isFile $isFile
    }
}

function Test-Root {
    param (
        [string]$Path
    )

    $Path = $Path.TrimEnd('\')
    $rootPath = [System.IO.Path]::GetPathRoot($Path)
    if ($Path -eq $rootPath) {
        return $true
    } else {
        return $false
    }
}

function Check_Conditions {
    param (
        [string]$f1, 
        [string]$f2, 
        [bool]$rb, 
        [bool]$isb, 
        [string]$bu, 
        [string]$name1,
        [string]$name2
    )

    if (($f1 -eq "") -or ($f2 -eq "")) {
        $warning.Content = "Bắt buộc nhập đường dẫn cho $name1, $name2."
        return $false
    }

    if (-not (Test-Path $f1)) {
        $warning.Content = "Đường dẫn tại $name1 sai, không tồn tại hoặc không thể truy cập được."
        return $false
    }

    if (-not (Test-Path $f2)) {
        $warning.Content = "Đường dẫn tại $name2 sai, không tồn tại hoặc không thể truy cập được."
        return $false
    }

    if ((Test-Root -Path $f2) -eq $true) {
        $warning.Content = "$name2 không được là một ổ đĩa. Ví dụ, không được là D:\ hoặc E:\ mà phải là một thư mục cụ thể như 'D:\(tên thư mục)'..."
        return $false
    }

    if ($isb) {
        if ([string]::IsNullOrEmpty($bu)) {
            $warning.Content = "Bạn đã bật Dự phòng cho $name2 nhưng chưa nhập đường dẫn cho thư mục dự phòng. Nếu không cần, hãy tắt đi."
            return $false
        }
        if (-not (Test-Path $bu)) {
            $warning.Content = "Đường dẫn thư mục Dự phòng của $name2 sai, không tồn tại hoặc không thể truy cập được."
            return $false
        }
    }

    if (($f1 -eq $f2) -or ($f1 -eq $bu) -or ($f2 -eq $bu)) {
        $warning.Content = "Đường dẫn đến các thư mục $name1, $name2 và Dự phòng không được trùng nhau."
        return $false
    }

    return $true
}

function On_Off {
    param (
        [bool]$Value
    )
    $folder1.IsEnabled = $Value
    $folder2.IsEnabled = $Value
    $RecycleBin.IsEnabled = $Value
    $isBackup.IsEnabled = $Value
    $BackupPath.IsEnabled = $Value
    $rptime.IsEnabled = $Value
    $autosyn.IsEnabled = $Value
    $testTime.IsEnabled = $Value
    $syncMore.IsEnabled = $Value
    if ($syncMore.IsChecked -eq $true) {
        $ongr2.IsEnabled = $Value
        $ongr3.IsEnabled = $Value
        $ongr4.IsEnabled = $Value
        $ongr5.IsEnabled = $Value
    } else {
        $isLog.IsEnabled = $Value
    }
    if ($ongr2.IsChecked -eq $true) {
        $folder3.IsEnabled = $Value
        $folder4.IsEnabled = $Value
        $RecycleBin2.IsEnabled = $Value
        $isBackup2.IsEnabled = $Value
        $BackupPath2.IsEnabled = $Value
    }
    if ($ongr3.IsChecked -eq $true) {
        $folder5.IsEnabled = $Value
        $folder6.IsEnabled = $Value
        $RecycleBin3.IsEnabled = $Value
        $isBackup3.IsEnabled = $Value
        $BackupPath3.IsEnabled = $Value
    }
    if ($ongr4.IsChecked -eq $true) {
        $folder7.IsEnabled = $Value
        $folder8.IsEnabled = $Value
        $RecycleBin4.IsEnabled = $Value
        $isBackup4.IsEnabled = $Value
        $BackupPath4.IsEnabled = $Value
    }
    if ($ongr5.IsChecked -eq $true) {
        $folder9.IsEnabled = $Value
        $folder10.IsEnabled = $Value
        $RecycleBin5.IsEnabled = $Value
        $isBackup5.IsEnabled = $Value
        $BackupPath5.IsEnabled = $Value
    }
}

# Đường dẫn đến chương trình muốn tạo shortcut
$programPath = if ($batFilePath) {
    $batFilePath
} elseif ($PSCommandPath) {
    $PSCommandPath
} elseif ($MyInvocation.MyCommand.Path) {
    $MyInvocation.MyCommand.Path
} else {
    [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
}
function Is_Startup {
    param (
        [bool]$On
    )
    # Đường dẫn đến thư mục khởi động của người dùng hiện tại
    $startupFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup")
    # Đường dẫn đầy đủ của shortcut
    $shortcutPath = [System.IO.Path]::Combine($startupFolder, "SaoLuuMini.lnk")
    if ($On) {
        # Tạo một đối tượng WScript.Shell
        $WScriptShell = New-Object -ComObject WScript.Shell
        # Tạo một shortcut tại vị trí đã chỉ định
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        # Thiết lập các thuộc tính cho shortcut
        $shortcut.TargetPath = $programPath
        $shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($programPath)
        $shortcut.WindowStyle = 1
        $shortcut.Save()
    } else {
        # Kiểm tra xem shortcut có tồn tại hay không và xóa nó
        if (Test-Path -Path $shortcutPath) {
            Remove-Item -Path $shortcutPath -Force
        }
    }
}

# Biến toàn cục để điều khiển vòng lặp và quản lý runspace
$global:syncRunning = $false
$global:asyncResult = $null
$global:runspace = $null

# Hàm để bắt đầu đồng bộ
function Start-Sync {
    param (
        [string]$f1, 
        [string]$f2, 
        [bool]$rb, 
        [bool]$isb, 
        [string]$bu, 
        [bool]$isl, 
        [int]$tm, 
        [System.Windows.Controls.TextBox]$logBox,
        [bool]$on2,
        [string]$f3,
        [string]$f4,
        [bool]$rb2,
        [bool]$isb2,
        [string]$bu2,
        [bool]$on3,
        [string]$f5,
        [string]$f6,
        [bool]$rb3,
        [bool]$isb3,
        [string]$bu3,
        [bool]$on4,
        [string]$f7,
        [string]$f8,
        [bool]$rb4,
        [bool]$isb4,
        [string]$bu4,
        [bool]$on5,
        [string]$f9,
        [string]$f10,
        [bool]$rb5,
        [bool]$isb5,
        [string]$bu5,
        [bool]$more
    )

    $warning.Content = ""
    if (-not (Check_Conditions -f1 $f1 -f2 $f2 -rb $rb -isb $isb -bu $bu -name1 "F1" -name2 "F2")) {return}

    if ($more -and $on2 -and (-not (Check_Conditions -f1 $f3 -f2 $f4 -rb $rb2 -isb $isb2 -bu $bu2 -name1 "F3" -name2 "F4"))) {return}

    if ($more -and $on3 -and (-not (Check_Conditions -f1 $f5 -f2 $f6 -rb $rb3 -isb $isb3 -bu $bu3 -name1 "F5" -name2 "F6"))) {return}

    if ($more -and $on4 -and (-not (Check_Conditions -f1 $f7 -f2 $f8 -rb $rb4 -isb $isb4 -bu $bu4 -name1 "F7" -name2 "F8"))) {return}

    if ($more -and $on5 -and (-not (Check_Conditions -f1 $f9 -f2 $f10 -rb $rb5 -isb $isb5 -bu $bu5 -name1 "F9" -name2 "F10"))) {return}

    if ($tm -lt 5) {
        $warning.Content = "Thời gian kiểm tra và đồng bộ cần >= 5 để tránh tốn tài nguyên không cần thiết. Nên đặt từ 60 giây."
        return
    }

    $warning.Content = ""
    # Ngăn không cho đóng cửa sổ WPF
    $window.Add_Closing({
        $_.Cancel = $true
    })

    $run.Visibility = 'Hidden'
    $stop.Visibility = 'Visible'
    On_Off -Value $false

    # Định nghĩa script block, truyền tham số để chạy Sync-Folder
    $scriptBlock = {
        param ($f1, $f2, $rb, $isb, $bu, $isl, $tm, $logBox, $on2, $f3, $f4, $rb2, $isb2, $bu2, $on3, $f5, $f6, $rb3, $isb3, $bu3, $on4, $f7, $f8, $rb4, $isb4, $bu4, $on5, $f9, $f10, $rb5, $isb5, $bu5, $more)

        # Hàm ghi thông báo vào logBox
        function Write-Log {
            param (
                [string]$message
            )
            $logBox.Dispatcher.Invoke([action]{
                $logBox.AppendText("$message`n")
                $logBox.ScrollToEnd()
            })
        }

        function Adjust_CreationTimes {
            param (
                [System.IO.FileSystemInfo[]]$items,
                [bool]$folder
            )
        
            function Adjust_Time {
                param (
                    [datetime]$dateTime,
                    [int]$secondsToAdd
                )
                return $dateTime.AddSeconds($secondsToAdd)
            }
        
            $exclude = {($_.FullName -inotmatch '`$RECYCLE.BIN') -and ($_.FullName -inotmatch 'System Volume Information') -and ($_.FullName -inotmatch 'Recycle Bin')}
        
            if ($folder) {
                $groupedItems = $items | Where-Object $exclude | Group-Object -Property CreationTime
            } else {
                $groupedItems = $items | Where-Object $exclude | Group-Object -Property { "$($_.Extension)-$($_.CreationTime)" }
            }
        
            foreach ($group in $groupedItems) {
                if ($group.Count -gt 1) {
                    if ($folder) {
                        $creationTime = [datetime]::Parse($group.Name)
                    } else {
                        $creationTime = $group.Group[0].CreationTime
                    }
        
                    $count = $group.Count
                    for ($i = 0; $i -lt $count; $i++) {
                        $item = $group.Group[$i]
                        if ($null -ne $item.CreationTime) {
                            $newTime = Adjust_Time -dateTime $creationTime -secondsToAdd ($count - $i - 1)
                            # Kiểm tra xem tệp có thuộc tính read-only không
                            $isReadOnly = $item.Attributes -band [System.IO.FileAttributes]::ReadOnly
        
                            if ($isReadOnly) {
                                # Loại bỏ thuộc tính read-only
                                $item.Attributes = $item.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
                            }
        
                            # Đặt lại thời gian tạo
                            Set-ItemProperty -LiteralPath $item.FullName -Name CreationTime -Value $newTime -Force
        
                            if ($isReadOnly) {
                                # Đặt lại thuộc tính read-only
                                $item.Attributes = $item.Attributes -bor [System.IO.FileAttributes]::ReadOnly
                            }
                        }
                    }
                }
            }
        }

        function Sync-Folder {
            param (
                [string]$F1,
                [string]$F2,
                [bool]$Recycle,
                [bool]$Backup,
                [string]$BackupDir,
                [bool]$Onlog
            )    
        
            function Get-RelativeName {
                param (
                    [string]$itemPath,
                    [bool]$isFile,
                    [string]$basePath
                )

                # Kiểm tra nếu itemPath có chứa các thư mục cần loại trừ
                if (($itemPath -match '\$RECYCLE\.BIN') -or ($itemPath -match 'System Volume Information') -or ($itemPath -match 'Recycle Bin')) {
                    return
                }
            
                $item = Get-Item -LiteralPath $itemPath -Force
            
                if ($isFile) {
                    $idString = "$($item.Length),$($item.CreationTime.ToString('yyyyMMddHHmmss')),$($item.LastWriteTime.ToString('yyyyMMddHHmmss')),$($item.Extension)"
                } else {
                    $idString = "$($item.CreationTime.ToString('yyyyMMddHHmmss'))"
                }
            
                $relativePath = $itemPath.Substring($basePath.Length).TrimStart('\')
                $parentPath = Split-Path -Parent $relativePath
            
                if ($parentPath -eq '') {
                    $relativeName = $idString
                } else {
                    $relativeName = Join-Path -Path $parentPath -ChildPath $idString
                }
            
                return $relativeName
            }

            function Move-ToBackup {
                param (
                    [string]$itemPath,
                    [string]$f2,
                    [string]$backup,
                    [bool]$file
                )
            
                $relativePath = $itemPath.Substring($f2.Length).TrimStart('\')
                $destinationPath = Join-Path -Path $backup -ChildPath $relativePath
            
                # Hàm để tạo thư mục đích và gán thuộc tính cho chúng
                # Đây gọi là hàm đệ quy, chính nó gọi nó để tạo vòng lặp 
                function CreateParent {
                    param (
                        [string]$sourceDir,
                        [string]$destDir
                    )
                    
                    # Kiểm tra nếu thư mục đích không tồn tại
                    if (-not (Test-Path -LiteralPath $destDir)) {
                        $parentDirPath = Split-Path -Path $sourceDir -Parent
                        $destParentDirPath = Split-Path -Path $destDir -Parent
                        
                        # Đệ quy để tạo thư mục cha trước nếu cần thiết
                        CreateParent -sourceDir $parentDirPath -destDir $destParentDirPath
            
                        # Tạo thư mục hiện tại
                        New-Item -Path $destDir -ItemType Directory -Force
            
                        # Lấy và gán thuộc tính từ thư mục nguồn
                        $parentDirItem = Get-Item -LiteralPath $sourceDir -Force
                        $newDir = Get-Item -LiteralPath $destDir
                        $newDir.CreationTime = $parentDirItem.CreationTime
                        $newDir.Attributes = $parentDirItem.Attributes
                    }
                }
            
                # Gọi hàm đệ quy để tạo thư mục và gán thuộc tính
                $destinationDir = Split-Path -Path $destinationPath -Parent
                CreateParent -sourceDir (Split-Path -Path $itemPath -Parent) -destDir $destinationDir
            
                # Di chuyển tệp hoặc thư mục
                if ($file) {
                    Move-Item -LiteralPath $itemPath -Destination $destinationPath -Force
                } else {
                    Move-Item -LiteralPath $itemPath -Destination $destinationPath -Force -Recurse
                }
            }

            function Move-ToRecycleBin {
                param (
                    [string]$Path
                )
                    $shell = New-Object -ComObject "Shell.Application"
                    $folder = $shell.Namespace([System.IO.Path]::GetDirectoryName($Path))
                    $item = $folder.ParseName([System.IO.Path]::GetFileName($Path))
                    $item.InvokeVerb("delete")
            }
            $sourceAll = Get-ChildItem -LiteralPath $F1 -Recurse -Force -EA 0
            $targetAll = Get-ChildItem -LiteralPath $F2 -Recurse -Force -EA 0

            $sourceDirs = $sourceAll | Where-Object { $_.PSIsContainer }
            $targetDirs = $targetAll | Where-Object { $_.PSIsContainer }
            $sourceDirNames = @{}
            $targetDirNames = @{}

            # Kiểm tra các nhóm và điều chỉnh CreationTimes nếu có nhóm nào có hơn 1 thư mục
            Adjust_CreationTimes -items $sourceDirs -folder $true
            Adjust_CreationTimes -items $targetDirs -folder $true

            # Tạo relativeName cho các thư mục
            foreach ($item in $sourceDirs) {
                $relativeName = Get-RelativeName -itemPath $item.FullName -isFile $false -basePath $F1
                if ($relativeName) {
                    $sourceDirNames[$relativeName] = $item.FullName
                }
            }
        
            foreach ($item in $targetDirs) {
                $relativeName = Get-RelativeName -itemPath $item.FullName -isFile $false -basePath $F2
                if ($relativeName) {
                    $targetDirNames[$relativeName] = $item.FullName
                }
            }

            # So sánh và đổi tên các thư mục tại F2 khác với F1
            foreach ($relativeName in $sourceDirNames.Keys) {
                if ($targetDirNames.ContainsKey($relativeName)) {
                    $sourceItem = $sourceDirNames[$relativeName]
                    $targetItem = $targetDirNames[$relativeName]
                    $sourceName = Split-Path -Leaf $sourceItem
                    if ($sourceName -ne (Split-Path -Leaf $targetItem)) {
                        try {
                            Rename-Item -LiteralPath $targetItem -NewName $sourceName -Force
                            if ($Onlog) {
                                Write-Log "ĐỔI TÊN $targetItem thành $sourceName theo bản gốc tại F1."
                            } else {Write-Log ""}
                        } catch {
                            if ($Onlog) {
                                Write-Log "ĐỔI TÊN không thành công $targetItem sang $sourceName theo bản gốc tại F1. Do không có quyền quản trị hoặc đối tượng đang được sử dụng. Sẽ thử lại sau."
                            }
                        }
                    }
                }
            }

            $sourceFiles = $sourceAll | Where-Object { -not $_.PSIsContainer }
            $targetFiles = $targetAll | Where-Object { -not $_.PSIsContainer }
            $sourceFileNames = @{}
            $targetFileNames = @{}

            # Kiểm tra các nhóm và điều chỉnh CreationTimes nếu có nhóm nào có hơn 1 thư mục
            Adjust_CreationTimes -items $sourceFiles -folder $false
            Adjust_CreationTimes -items $targetFiles -folder $false
            
            # Tạo relativeName cho các file
            foreach ($item in $sourceFiles) {
                $relativeName = Get-RelativeName -itemPath $item.FullName -isFile $true -basePath $F1
                if ($relativeName) {
                    $sourceFileNames[$relativeName] = $item.FullName
                }
            }

            foreach ($item in $targetFiles) {
                $relativeName = Get-RelativeName -itemPath $item.FullName -isFile $true -basePath $F2
                if ($relativeName) {
                    $targetFileNames[$relativeName] = $item.FullName
                }
            }

            # So sánh và đổi tên các file tại F2 khác với F1
            foreach ($relativeName in $sourceFileNames.Keys) {
                if ($targetFileNames.ContainsKey($relativeName)) {
                    $sourceItem = $sourceFileNames[$relativeName]
                    $targetItem = $targetFileNames[$relativeName]
                    $sourceName = Split-Path -Leaf $sourceItem
                    if ($sourceName -ne (Split-Path -Leaf $targetItem)) {
                        try {
                            Rename-Item -LiteralPath $targetItem -NewName $sourceName -Force
                            if ($Onlog) {
                                Write-Log "ĐỔI TÊN $targetItem thành $sourceName theo bản gốc tại F1."
                            }
                        } catch {
                            if ($Onlog) {
                                Write-Log "ĐỔI TÊN không thành công $targetItem sang $sourceName theo bản gốc tại F1. Do không có quyền quản trị hoặc đối tượng đang được sử dụng. Sẽ thử lại sau."
                            }
                        }
                    } 
                }
            }            
        
            # Xử lý các thư mục tại F2 không có trong F1
            foreach ($relativeName in $targetDirNames.Keys) {
                if (-not $sourceDirNames.ContainsKey($relativeName)) {
                    $targetItem = $targetDirNames[$relativeName]
                    if ($Backup) {
                        try {
                            Move-ToBackup -itemPath $targetItem -f2 $F2 -backup $BackupDir -file $false
                            if ($Onlog) {
                                Write-Log "DI CHUYỂN $targetItem vào thư mục Dự phòng vì bản gốc từ F1 không còn tồn tại hoặc đã thay đổi."
                            }
                        } catch {
                            if ($Onlog) {
                                Write-Log "DI CHUYỂN không thành công $targetItem vào thư mục Dự phòng dù bản gốc từ F1 không còn tồn tại hoặc đã thay đổi. Do không có quyền quản trị hoặc đối tượng đang được sử dụng. Sẽ thử lại sau."
                            }
                        } 
                    } 
                    if ($Recycle) {
                        try {
                            Move-ToRecycleBin -Path $targetItem
                            if ($Onlog) {
                                Write-Log "XÓA $targetItem vào Thùng rác vì bản gốc từ F1 không còn tồn tại hoặc đã thay đổi."
                            }
                        } catch {
                            if ($Onlog) {
                                Write-Log "XÓA không thành công $targetItem vào Thùng rác dù bản gốc từ F1 không còn tồn tại hoặc đã thay đổi. Do không có quyền quản trị hoặc đối tượng đang được sử dụng. Sẽ thử lại sau."
                            }
                        }
                    }
                }
            }
        
            # Xử lý các file không trùng relativeName với sourceFiles. Nghĩa là file không còn tồn tại ở F1 hoặc file tại F1 vẫn còn nhưng đã được sửa đổi. 
            foreach ($relativeName in $targetFileNames.Keys) {
                if (-not $sourceFileNames.ContainsKey($relativeName)) {
                    $targetItem = $targetFileNames[$relativeName]
                    # Kiểm tra xem file có tồn tại không (bởi vì trước đó các folder không tồn tại đã được xử lý, rất có thể file cũng đã được xử lý rồi, do đó cần kiểm tra lại)
                    if (Test-Path -LiteralPath $targetItem) {
                        if ($Backup) {
                            try {
                                Move-ToBackup -itemPath $targetItem -f2 $F2 -backup $BackupDir -file $true
                                if ($Onlog) {
                                    Write-Log "DI CHUYỂN $targetItem vào thư mục Dự phòng vì bản gốc từ F1 không còn tồn tại hoặc đã thay đổi."
                                }
                            } catch {
                                if ($Onlog) {
                                    Write-Log "DI CHUYỂN không thành công $targetItem vào thư mục Dự phòng dù bản gốc từ F1 không còn tồn tại hoặc đã thay đổi. Do không có quyền quản trị hoặc đối tượng đang được sử dụng. Sẽ thử lại sau."
                                }
                            }
                        } 
                        if ($Recycle) {
                            try {
                                Move-ToRecycleBin -Path $targetItem
                                if ($Onlog) {
                                    Write-Log "XÓA $targetItem vào Thùng rác vì bản gốc từ F1 không còn tồn tại hoặc đã thay đổi."
                                }
                            } catch {
                                if ($Onlog) {
                                    Write-Log "XÓA không thành công $targetItem vào Thùng rác dù bản gốc từ F1 không còn tồn tại hoặc đã thay đổi. Do không có quyền quản trị hoặc đối tượng đang được sử dụng. Sẽ thử lại sau."
                                }
                            }
                        }
                    }   
                }
            }
        
            # Kiểm tra các thư mục và file tại f1 có relativeName không trùng với f2. Nghĩa là thư mục và file mới, cần được sao chép sang f2.
            foreach ($relativeName in $sourceDirNames.Keys) {
                $sourceItem = $sourceDirNames[$relativeName]
                if (-not $targetDirNames.ContainsKey($relativeName)) {
                    if ($Onlog) {
                        Write-Log "Thư mục $sourceItem sẽ được đồng bộ sang F2."
                    }
                }
            }
        
            foreach ($relativeName in $sourceFileNames.Keys) {
                $sourceItem = $sourceFileNames[$relativeName]
                if (-not $targetFileNames.ContainsKey($relativeName)) {
                    if ($Onlog) {
                        Write-Log "Tệp $sourceItem sẽ được đồng bộ sang F2."
                    }
                }  
            }
            $driveF1 = [System.IO.DriveInfo]::new($F1).Name
            # Chạy robocopy nhưng loại bỏ các thư mục cụ thể. 
            robocopy $F1 $F2 /MIR /COPYALL /DCOPY:DAT /Z /IT /R:1 /W:3 /XD "$driveF1`$RECYCLE.BIN" "$driveF1`System Volume Information" "$driveF1`Recycle Bin" 
        }

        # Chạy Sync-Folder lần đầu
        Sync-Folder -F1 $f1 -F2 $f2 -Recycle $rb -Backup $isb -BackupDir $bu -Onlog $isl

        if ($more -and $on2) {
            Sync-Folder -F1 $f3 -F2 $f4 -Recycle $rb2 -Backup $isb2 -BackupDir $bu2
        }
        
        if ($more -and $on3) {
            Sync-Folder -F1 $f5 -F2 $f6 -Recycle $rb3 -Backup $isb3 -BackupDir $bu3
        }
        
        if ($more -and $on4) {
            Sync-Folder -F1 $f7 -F2 $f8 -Recycle $rb4 -Backup $isb4 -BackupDir $bu4
        }
        
        if ($more -and $on5) {
            Sync-Folder -F1 $f9 -F2 $f10 -Recycle $rb5 -Backup $isb5 -BackupDir $bu5
        }

        # Đặt biến điều khiển thành true
        $global:syncRunning = $true

        while ($true) {
            if (-not [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.SessionStateProxy.GetVariable("syncRunning")) {
                break
            }
            Sync-Folder -F1 $f1 -F2 $f2 -Recycle $rb -Backup $isb -BackupDir $bu -Onlog $isl

            if ($more -and $on2) {
                Sync-Folder -F1 $f3 -F2 $f4 -Recycle $rb2 -Backup $isb2 -BackupDir $bu2
            }
            
            if ($more -and $on3) {
                Sync-Folder -F1 $f5 -F2 $f6 -Recycle $rb3 -Backup $isb3 -BackupDir $bu3
            }
            
            if ($more -and $on4) {
                Sync-Folder -F1 $f7 -F2 $f8 -Recycle $rb4 -Backup $isb4 -BackupDir $bu4
            }
            
            if ($more -and $on5) {
                Sync-Folder -F1 $f9 -F2 $f10 -Recycle $rb5 -Backup $isb5 -BackupDir $bu5
            }

            # Yêu cầu hệ thống thu gom và giải phóng bộ nhớ không cần thiết
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
            
            Start-Sleep -Seconds $tm
        }
    }

    # Tạo một runspace mới cho script block
    $initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace($initialSessionState)
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()

    # Đặt runspace mặc định để script block có thể truy cập biến toàn cục
    [System.Management.Automation.Runspaces.Runspace]::DefaultRunspace = $runspace

    # Phải khai báo cả các tham số ở đây
    $powershell = [powershell]::Create().AddScript($scriptBlock).AddArgument($f1).AddArgument($f2).AddArgument($rb).AddArgument($isb).AddArgument($bu).AddArgument($isl).AddArgument($tm).AddArgument($logBox).AddArgument($on2).AddArgument($f3).AddArgument($f4).AddArgument($rb2).AddArgument($isb2).AddArgument($bu2).AddArgument($on3).AddArgument($f5).AddArgument($f6).AddArgument($rb3).AddArgument($isb3).AddArgument($bu3).AddArgument($on4).AddArgument($f7).AddArgument($f8).AddArgument($rb4).AddArgument($isb4).AddArgument($bu4).AddArgument($on5).AddArgument($f9).AddArgument($f10).AddArgument($rb5).AddArgument($isb5).AddArgument($bu5).AddArgument($more)

    $powershell.Runspace = $runspace

    $global:runspace = $powershell
    $global:asyncResult = $global:runspace.BeginInvoke()
}

# Hàm để dừng đồng bộ
function Stop-Sync {
    if ($global:runspace -and $global:asyncResult) {
        $global:runspace.Stop()
        $global:runspace.Dispose()
        $global:runspace = $null
        $global:asyncResult = $null
    }

    # Cho phép đóng cửa sổ WPF trở lại
    $window.Add_Closing({
        $_.Cancel = $false
    })

    $stop.Visibility = 'Hidden'
    $run.Visibility = 'Visible'
    On_Off -Value $true
}

$txtGuide = "〖 1 〗 Phần mềm được xây dựng là sự kết hợp giữa các lệnh sao lưu, dự phòng bằng Powershell và robocopy. Khi Khởi chạy, phần mềm sẽ kiểm tra thư mục Nguồn và Đích, sau đó:`n    - Nếu phát hiện tại Nguồn có thư mục hoặc tệp tin đã đổi tên thì sẽ đổi tên cho bản sao tại Đích. `n    - Nếu phát hiện tại Nguồn có thư mục hoặc tệp tin đã bị xóa hoặc được chỉnh sửa thì sẽ di chuyển phiên bản cũ hơn tại Đích vào Thùng rác hoặc thư mục Dự phòng (tùy vào thiết lập của bạn). `n    - Sau khi làm xong hai việc trên, sẽ chạy robocopy với các thiết lập /MIR /COPYALL /DCOPY:DAT /Z /IT để sao chép các thư mục và tệp tin mới (hoặc có phiên bản khác với Đích) để ghi đè sang Đích. `n`nToàn bộ thông tin, bao gồm cả phân quyền đều sẽ được sao chép, do đó bạn cần mở phần mềm bằng cách chuột phải và chọn `"Run as admin`", nếu không, phần mềm sẽ không hoạt động được. `n`n〖 2 〗 Nhập đường dẫn cho Nguồn và Đích theo dạng: D:\ThuMucCuaBan. Lưu ý, khi bấm đúp vào ô đường dẫn, mọi nội dung tại đây đều sẽ được bôi đen. `n`n〖 3 〗 Nguồn có thể là một thư mục hoặc ổ đĩa, nhưng Đích chỉ có thể là thư mục. Nếu bạn đặt Đích là ổ đĩa, phần mềm sẽ từ chối đồng bộ. `n`n〖 4 〗 Mặc định, các tệp/thư mục của Đích khác với Nguồn sẽ được đưa vào thùng rác. Nếu bạn tắt tùy chọn này, các tệp/thư mục khác biệt sẽ bị ghi đè và xóa rỗng, chỉ có thể lấy lại nếu dùng phần mềm khôi phục dữ liệu. `n`n〖 5 〗 Bạn có thể đưa các tệp/thư mục của Đích khác với Nguồn vào một thư mục Dự phòng, lúc này, tùy chọn Thùng rác sẽ được tắt. `n`n〖 6 〗 Nếu có nhiều hơn một Nguồn cần đồng bộ, hãy chọn 'Thêm nữa', cửa sổ phần mềm sẽ được mở rộng để bạn thêm vào tối đa 4 Nguồn khác. Như vậy, phần mềm này cho phép bạn đồng bộ tối đa 5 Nguồn. Nếu có nhiều hơn 5 Nguồn cần đồng bộ, bạn chỉ cần chuột phải vào phần mềm, `"Run as admin`" để mở thêm một cửa sổ làm việc mới. `n`n〖 7 〗 Mặc định, phần mềm sẽ chạy kiểm tra và sao lưu sau mỗi 60 giây, bạn có thể chỉnh lại thời gian này, nhưng không được nhỏ hơn 5 giây. Theo kinh nghiệm của tôi, tốt nhất nên từ 60 giây trở lên, bởi trong 60 giây thì thư mục Nguồn của bạn sẽ chưa có nhiều thay đổi đáng kể. Nhưng mọi quyết định nằm ở bạn! `n`n    Lưu ý: Đối với những Nguồn có hàng chục nghìn thư mục và tệp tin, việc kiểm tra và sao lưu sẽ cần thời gian. Để biết nên thiết lập thời gian sao lưu sau mỗi bao nhiêu giây thì hợp lý, hãy nhập đường dẫn cho mọi Nguồn và Đích bạn cần, sau đó bấm 'Tính thời gian', phần mềm sẽ báo cho bạn biết với lượng dữ liệu hiện tại thì tốt nhất nên thiết lập thời gian là bao nhiêu. `n`n〖 8 〗 Nếu chọn 'Khởi động cùng Windows', phần mềm sẽ tự động mở mỗi lần Windows được khởi động. `n`n〖 9 〗 Nếu chọn 'Tự động chạy', mỗi khi phần mềm được mở, nó sẽ tự chạy sao lưu mà không cần bạn phải bấm vào nút 'Khởi chạy'. Kết hợp giữa 'Khởi động cùng Windows' và 'Tự động chạy', sẽ đảm bảo rằng việc sao lưu các thư mục của bạn sẽ luôn diễn ra mà không cần bạn phải can thiệp. `n`n〖 10 〗 Khi chọn 'Mở báo cáo', cửa sổ phần mềm sẽ mở rộng thêm một bảng phụ để bạn theo dõi cách các tệp tin và thư mục được xử lý, có mục nào mới được thêm vào Nguồn, mục nào mới được đổi tên, mục nào sẽ được đồng bộ hoặc bị xóa, v.v.. `n`nChức năng 'Mở báo cáo' sẽ bị khóa nếu tùy chọn 'Thêm nữa' được bật, bởi xem báo cáo của nhiều Nguồn cùng lúc là không cần thiết. `n`n〖 11 〗 Sau khi nhập đầy đủ các đường dẫn Nguồn và Đích, thiết lập xong các tùy chọn, hãy bấm vào nút 'Lưu cấu hình'. Các thiết lập của bạn sẽ được lưu tại HKEY_CURRENT_USER\SOFTWARE\SaoLuuMini. Chỉ sau khi cấu hình được lưu, tùy chọn 'Tự động chạy' mới có thể hoạt động. `n`n〖 12 〗 Khi phần mềm đang chạy sao lưu, nó sẽ bị khóa, không cho phép tắt đi để đảm bảo an toàn dữ liệu. Nếu muốn tắt phần mềm, bạn cần bấm nút 'Ngừng lại', sau đó tắt chương trình. `n`n〖 13 〗 Khi bấm 'Ẩn xuống', phần mềm sẽ được ẩn vào khay hệ thống và vẫn tiếp tục công tác sao lưu nếu trước đó đang được khởi chạy. `n`n〖 14 〗 Trường hợp cả thư mục mẹ và thư mục con hoặc tệp tin bên trong đều được đổi tên. Phần mềm sẽ đổi tên thư mục mẹ trước, sau đó, nó sẽ báo không thể đổi tên thư mục con hoặc tệp tin bên trong. Đây là một báo lỗi giả, bạn không cần bận tâm. `n`n〖 15 〗 Phần mềm SaoLuuMini 1.0 được viết bởi facebook.com/nqhaivn/, phát hành ngày 19/06/2024. `n`n    Mọi hành vi chỉnh sửa lại mã nguồn mà chưa được sự đồng ý bằng văn bản của tác giả thì đều là trộm cắp. `n`n    Mọi góp ý, báo lỗi, có nhu cầu tùy chỉnh phần mềm theo sở thích của bản thân hoặc muốn đề nghị thiết kế phần mềm khác, vui lòng liên lạc với email: nqhai86@gmail.com`n`n    Trân trọng!"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Drawing
# Phải gọi lớp này mới tạo được chức năng ẩn trên khay System icon
Add-Type -AssemblyName System.Windows.Forms

$shell32Path = Join-Path -Path $env:SystemRoot -ChildPath "System32\DevicePairingWizard.exe"
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($shell32Path)
$bitmapSource = [System.Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
    $icon.Handle,
    [System.Windows.Int32Rect]::Empty,
    [System.Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
)

# Tạo đối tượng Application, xem dòng mã dưới cùng để hiểu thêm
$app = [System.Windows.Application]::new()

$window = New-Object Windows.Window
$window.Title = "SaoLuuMini NQH"
$window.MaxHeight = 210
$window.MinHeight = 210
$window.MinWidth = 800
$window.MaxWidth = 800
$window.WindowStartupLocation = "CenterScreen"
$window.FontSize = 13
$window.Icon = $bitmapSource
# $window.Foreground = [System.Windows.Media.Brushes]::White
# $window.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(32, 32, 32))

# Tạo NotifyIcon để hiển thị trên khay hệ thống
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = $icon
$notifyIcon.Visible = $true
$notifyIcon.Text = "SaoLuuMini"

# Định nghĩa sự kiện cho NotifyIcon khi bấm chuột
$notifyIcon.add_Click({
    if ($window.WindowState -eq 'Minimized') {
        $window.WindowState = 'Normal'
        $window.ShowInTaskbar = $true
        $window.Show()
        $window.Activate()
    } else {
        $window.WindowState = 'Minimized'
        $window.ShowInTaskbar = $false
    }
})

$grid = New-Object System.Windows.Controls.Grid
# Tạo hàng cho Grid (chỉ có 1 cột nên không cần tạo cột)
$rowDef0 = New-Object System.Windows.Controls.RowDefinition
$rowDef1 = New-Object System.Windows.Controls.RowDefinition
$rowDef2 = New-Object System.Windows.Controls.RowDefinition
$rowDef3 = New-Object System.Windows.Controls.RowDefinition
$rowDef0.Height = New-Object System.Windows.GridLength(80)
$rowDef2.Height = New-Object System.Windows.GridLength(90)
# Ẩn hàng thứ 2 và 3
$rowDef1.Height = New-Object System.Windows.GridLength(0)
$rowDef3.Height = New-Object System.Windows.GridLength(0)
$grid.RowDefinitions.Add($rowDef0)
$grid.RowDefinitions.Add($rowDef1)
$grid.RowDefinitions.Add($rowDef2)
$grid.RowDefinitions.Add($rowDef3)

$canvas0 = New-Object Windows.Controls.Canvas
# Đặt canvas vào hàng thứ nhất
$canvas0.SetValue([System.Windows.Controls.Grid]::RowProperty, 0)
[void]$grid.Children.Add($canvas0)
$window.Content = $grid

#-------------------- Nhóm 1
$ongr1 = $null
$folder1 = $null
$folder2 = $null
$RecycleBin = $null
$isBackup = $null
$BackupPath = $null

Group_WPF -canvas $canvas0 -more $false -ongr ([ref]$ongr1) -top 5 -f1 ([ref]$folder1) -n1 "F1" -f2 ([ref]$folder2) -n2 "F2" -isR ([ref]$RecycleBin) -isB ([ref]$isBackup) -bu ([ref]$BackupPath) -color1 $true

#-------------------------------------------- canvas1 gắn vào row1
$canvas1 = New-Object Windows.Controls.Canvas
$canvas1.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
$canvas1.Visibility = 'Hidden'
[void]$grid.Children.Add($canvas1)

#-------------------- Nhóm 2
$ongr2 = $null
$folder3 = $null
$folder4 = $null
$RecycleBin2 = $null
$isBackup2 = $null
$BackupPath2 = $null

Group_WPF -canvas $canvas1 -more $true -ongr ([ref]$ongr2) -top 5 -f1 ([ref]$folder3) -n1 "F3" -f2 ([ref]$folder4) -n2 "F4" -isR ([ref]$RecycleBin2) -isB ([ref]$isBackup2) -bu ([ref]$BackupPath2) -color1 $false

#-------------------- Nhóm 3
$ongr3 = $null
$folder5 = $null
$folder6 = $null
$RecycleBin3 = $null
$isBackup3 = $null
$BackupPath3 = $null

Group_WPF -canvas $canvas1 -more $true -ongr ([ref]$ongr3) -top 70 -f1 ([ref]$folder5) -n1 "F5" -f2 ([ref]$folder6) -n2 "F6" -isR ([ref]$RecycleBin3) -isB ([ref]$isBackup3) -bu ([ref]$BackupPath3) -color1 $true

#-------------------- Nhóm 4
$ongr4 = $null
$folder7 = $null
$folder8 = $null
$RecycleBin4 = $null
$isBackup4 = $null
$BackupPath4 = $null

Group_WPF -canvas $canvas1 -more $true -ongr ([ref]$ongr4) -top 140 -f1 ([ref]$folder7) -n1 "F7" -f2 ([ref]$folder8) -n2 "F8" -isR ([ref]$RecycleBin4) -isB ([ref]$isBackup4) -bu ([ref]$BackupPath4) -color1 $false

#-------------------- Nhóm 5
$ongr5 = $null
$folder9 = $null
$folder10 = $null
$RecycleBin5 = $null
$isBackup5 = $null
$BackupPath5 = $null

Group_WPF -canvas $canvas1 -more $true -ongr ([ref]$ongr5) -top 210 -f1 ([ref]$folder9) -n1 "F9" -f2 ([ref]$folder10) -n2 "F10" -isR ([ref]$RecycleBin5) -isB ([ref]$isBackup5) -bu ([ref]$BackupPath5) -color1 $true

#-------------------------------------------- canvas2 gắn vào row2
$canvas2 = New-Object Windows.Controls.Canvas
$canvas2.SetValue([System.Windows.Controls.Grid]::RowProperty, 2)
$canvas2.Background = [Windows.Media.Brushes]::AliceBlue
[void]$grid.Children.Add($canvas2)

$txtTime1 = New-Object Windows.Controls.Label
$txtTime1.Content = "Sao lưu sau mỗi"
[Windows.Controls.Canvas]::SetLeft($txtTime1, 10)
[Windows.Controls.Canvas]::SetTop($txtTime1, 10)
[void]$canvas2.Children.Add($txtTime1)

$rptime = New-Object Windows.Controls.TextBox
$rptime.Width = 50
$rptime.Text = 60
[Windows.Controls.Canvas]::SetLeft($rptime, 120)
[Windows.Controls.Canvas]::SetTop($rptime, 15)
[void]$canvas2.Children.Add($rptime)

$rptime.Add_PreviewTextInput({
    $regex = [regex]::new("[^0-9]+")
    if ($regex.IsMatch($_.Text)) {
        $_.Handled = $true
    }
})

$txtTime2 = New-Object Windows.Controls.Label
$txtTime2.Content = "giây"
[Windows.Controls.Canvas]::SetLeft($txtTime2, 170)
[Windows.Controls.Canvas]::SetTop($txtTime2, 10)
[void]$canvas2.Children.Add($txtTime2)

$testTime = New-Object Windows.Controls.Button
$testTime.Content = "Tính thời gian"
$testTime.Width = 100
[Windows.Controls.Canvas]::SetLeft($testTime, 290)
[Windows.Controls.Canvas]::SetTop($testTime, 15)
$testTime.Background = [System.Windows.Media.Brushes]::LightCyan
$testTime.Cursor = [System.Windows.Input.Cursors]::Hand
[void]$canvas2.Children.Add($testtime)

$autoStart = New-Object Windows.Controls.CheckBox
$autoStart.Content = "Khởi động cùng Windows"
[Windows.Controls.Canvas]::SetLeft($autoStart, 395)
[Windows.Controls.Canvas]::SetTop($autoStart, 15)
[void]$canvas2.Children.Add($autoStart)

$autosyn = New-Object Windows.Controls.CheckBox
$autosyn.Content = "Tự động chạy"
[Windows.Controls.Canvas]::SetRight($autosyn, 10)
[Windows.Controls.Canvas]::SetTop($autosyn, 15)
[void]$canvas2.Children.Add($autosyn)

$stackPanel = New-Object Windows.Controls.StackPanel
$stackPanel.Height = 20
$stackPanel.Width = 100
[Windows.Controls.Canvas]::SetLeft($stackPanel, 10)
[Windows.Controls.Canvas]::SetTop($stackPanel, 40)
$stackPanel.Background = [System.Windows.Media.Brushes]::PaleGreen
[void]$canvas2.Children.Add($stackPanel)

$syncMore = New-Object Windows.Controls.CheckBox
$syncMore.Content = "Thêm nữa"
$syncMore.Margin = "0,2,0,0"
$syncMore.Cursor = [System.Windows.Input.Cursors]::Hand
[void]$stackPanel.Children.Add($syncMore)

$save = New-Object Windows.Controls.Button
$save.Content = "Lưu cấu hình"
$save.Width = 100
[Windows.Controls.Canvas]::SetLeft($save, 120)
[Windows.Controls.Canvas]::SetTop($save, 40)
$save.Background = [System.Windows.Media.Brushes]::LightYellow
$save.Cursor = [System.Windows.Input.Cursors]::Hand
[void]$canvas2.Children.Add($save)

$hidebar = New-Object Windows.Controls.Button
$hidebar.Content = "Ẩn xuống ▼"
$hidebar.Width = 100
[Windows.Controls.Canvas]::SetLeft($hidebar, 290)
[Windows.Controls.Canvas]::SetTop($hidebar, 40)
$hidebar.Background = [System.Windows.Media.Brushes]::LightCyan
$hidebar.Cursor = [System.Windows.Input.Cursors]::Hand
[void]$canvas2.Children.Add($hidebar)

$guide = New-Object Windows.Controls.Button
$guide.Content = "Hướng dẫn"
$guide.Width = 100
[Windows.Controls.Canvas]::SetLeft($guide, 395)
[Windows.Controls.Canvas]::SetTop($guide, 40)
$guide.Background = [System.Windows.Media.Brushes]::LightCyan
$guide.Cursor = [System.Windows.Input.Cursors]::Hand
[void]$canvas2.Children.Add($guide)

$stackPanel2 = New-Object Windows.Controls.StackPanel
$stackPanel2.Height = 20
$stackPanel2.Width = 100
[Windows.Controls.Canvas]::SetRight($stackPanel2, 120)
[Windows.Controls.Canvas]::SetTop($stackPanel2, 40)
$stackPanel2.Background = [System.Windows.Media.Brushes]::LemonChiffon
[void]$canvas2.Children.Add($stackPanel2)

$isLog = New-Object Windows.Controls.CheckBox
$isLog.Content = "Mở báo cáo"
$isLog.Margin = "0,2,0,0"
[void]$stackPanel2.Children.Add($isLog)

$run = New-Object Windows.Controls.Button
$run.Content = "Khởi chạy"
$run.Width = 100
[Windows.Controls.Canvas]::SetRight($run, 10)
[Windows.Controls.Canvas]::SetTop($run, 40)
$run.Background = [System.Windows.Media.Brushes]::PaleGreen
$run.Cursor = [System.Windows.Input.Cursors]::Hand
[void]$canvas2.Children.Add($run)

$stop = New-Object Windows.Controls.Button
$stop.Content = "Ngừng lại"
$stop.Width = 100
$stop.Visibility = 'Hidden'
[Windows.Controls.Canvas]::SetRight($stop, 10)
[Windows.Controls.Canvas]::SetTop($stop, 40)
$stop.Background = [System.Windows.Media.Brushes]::LightSalmon
$stop.Cursor = [System.Windows.Input.Cursors]::Hand
[void]$canvas2.Children.Add($stop)

$warning = New-Object Windows.Controls.Label
$warning.Content = ""
# Tự động giãn bề ngang
$warning.HorizontalAlignment = "Stretch"
$warning.Foreground = [System.Windows.Media.Brushes]::Red
[Windows.Controls.Canvas]::SetLeft($warning, 10)
[Windows.Controls.Canvas]::SetTop($warning, 60)
[void]$canvas2.Children.Add($warning)

# TextBox để hiển thị thông báo
$logBox = New-Object Windows.Controls.TextBox
$logBox.TextWrapping = "Wrap"
$logBox.VerticalScrollBarVisibility = "Auto"
$logBox.AcceptsReturn = $true
$logBox.IsReadOnly = $true
$logBox.SetValue([System.Windows.Controls.Grid]::RowProperty, 3)
[void]$grid.Children.Add($logBox)

$testTime.Add_Click({
    if ([string]::IsNullOrEmpty($folder1.Text) -or (-not (Test-Path $folder1.Text))) {
        $warning.Content = "Nhập đường dẫn khả dụng cho F1 trước khi tính thời gian."
        return
    }

    if (($syncMore.IsChecked -and $ongr2.IsChecked) -and ([string]::IsNullOrEmpty($folder3.Text) -or (-not (Test-Path $folder3.Text)))) {
        $warning.Content = "Nhập đường dẫn khả dụng cho F3 trước khi tính thời gian. Hoặc ngừng Bật đồng bộ cho F3."
        return
    }

    if (($syncMore.IsChecked -and $ongr3.IsChecked) -and ([string]::IsNullOrEmpty($folder5.Text) -or (-not (Test-Path $folder5.Text)))) {
        $warning.Content = "Nhập đường dẫn khả dụng cho F5 trước khi tính thời gian. Hoặc ngừng Bật đồng bộ cho F5."
        return
    }

    if (($syncMore.IsChecked -and $ongr4.IsChecked) -and ([string]::IsNullOrEmpty($folder7.Text) -or (-not (Test-Path $folder7.Text)))) {
        $warning.Content = "Nhập đường dẫn khả dụng cho F7 trước khi tính thời gian. Hoặc ngừng Bật đồng bộ cho F7."
        return
    }

    if (($syncMore.IsChecked -and $ongr5.IsChecked) -and ([string]::IsNullOrEmpty($folder9.Text) -or (-not (Test-Path $folder9.Text)))) {
        $warning.Content = "Nhập đường dẫn khả dụng cho F9 trước khi tính thời gian. Hoặc ngừng Bật đồng bộ cho F9."
        return
    }

    $startTime = [datetime]::Now
    $warning.Content = "Đang tính, chờ một chút..."
    Get-RelativeNameFolder -Path $folder1.Text
    if($syncMore.IsChecked -and $ongr2.IsChecked) {
        Get-RelativeNameFolder -Path $folder3.Text
    }
    if($syncMore.IsChecked -and $ongr3.IsChecked) {
        Get-RelativeNameFolder -Path $folder5.Text
    }
    if($syncMore.IsChecked -and $ongr4.IsChecked) {
        Get-RelativeNameFolder -Path $folder7.Text
    }
    if($syncMore.IsChecked -and $ongr5.IsChecked) {
        Get-RelativeNameFolder -Path $folder9.Text
    }
    $endTime = [datetime]::Now
    $duration = $endTime - $startTime
    $totalSeconds = $duration.TotalSeconds * 3
    $roundedSeconds = [math]::Round($totalSeconds)
    if ($roundedSeconds -le 5) {
        $warning.Content = "KẾT QUẢ: Giữa mỗi lần đồng bộ nên cách nhau tối thiểu 5 giây"
        $rptime.Text = 5
    } else {
        $warning.Content = "KẾT QUẢ: Giữa mỗi lần đồng bộ nên cách nhau tối thiểu $roundedSeconds giây"
        $rptime.Text = $roundedSeconds
    }
})

# Xác định hành động khi nhấn Button "Lưu cấu hình"
$save.Add_Click({
    $config = @{
        "folder1" = $folder1.Text
        "folder2" = $folder2.Text
        "RecycleBin" = $RecycleBin.IsChecked
        "isBackup" = $isBackup.IsChecked
        "BackupPath" = $BackupPath.Text
        "rptime" = $rptime.Text
		"autosyn" = $autosyn.IsChecked
        "more" = $syncMore.IsChecked
        "ongr2" = $ongr2.IsChecked
        "folder3" = $folder3.Text
        "folder4" = $folder4.Text
        "RecycleBin2" = $RecycleBin2.IsChecked
        "isBackup2" = $isBackup2.IsChecked
        "BackupPath2" = $BackupPath2.Text
        "ongr3" = $ongr3.IsChecked
        "folder5" = $folder5.Text
        "folder6" = $folder6.Text
        "RecycleBin3" = $RecycleBin3.IsChecked
        "isBackup3" = $isBackup3.IsChecked
        "BackupPath3" = $BackupPath3.Text
        "ongr4" = $ongr4.IsChecked
        "folder7" = $folder7.Text
        "folder8" = $folder8.Text
        "RecycleBin4" = $RecycleBin4.IsChecked
        "isBackup4" = $isBackup4.IsChecked
        "BackupPath4" = $BackupPath4.Text
        "ongr5" = $ongr5.IsChecked
        "folder9" = $folder9.Text
        "folder10" = $folder10.Text
        "RecycleBin5" = $RecycleBin5.IsChecked
        "isBackup5" = $isBackup5.IsChecked
        "BackupPath5" = $BackupPath5.Text
        "autoStart" = $autoStart.IsChecked
    }

	# Kiểm tra xem khóa đăng ký tồn tại không thì xóa đi (để xóa cấu hình cũ)
	if (Test-Path "HKCU:\Software\SaoLuuMini") {
		Remove-Item -Path "HKCU:\Software\SaoLuuMini" -Recurse -Force
	}

    # Lưu giá trị cho từng biến vào các khóa riêng biệt trong registry
    try {
        # Tạo mới khóa
        New-Item -Path "HKCU:\Software\SaoLuuMini" -Force

        foreach ($key in $config.Keys) {
            Set-ItemProperty -Path "HKCU:\Software\SaoLuuMini" -Name $key -Value $config[$key]
        }
        $warning.Content = "Cấu hình đã được lưu."
    }
    catch {
        $warning.Content = "Không thể truy cập được vào Registry HKCU:\Software để lưu cấu hình, hãy cấp quyền cho ứng dụng."
    }

    $autosynValue = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "autosyn"
    if ($autosynValue -eq $true) {
        $autosyn.Content = "Tự chạy [Bật]"
	} else {
        $autosyn.Content = "Tự động chạy"
    }
})

# Kiểm tra xem khóa đăng ký tồn tại và có chứa cấu hình không
if (Test-Path "HKCU:\Software\SaoLuuMini") {
	# RecycleBin mặc định là true để ngăn việc đồng bộ nhầm mất dữ liệu.
	$RecycleBin.IsChecked = $true
	$isBackup.IsChecked = $false
	$autosyn.IsChecked = $false
    $syncMore.IsChecked = $false
    $ongr2.IsChecked = $false
    $RecycleBin2.IsChecked = $true
	$isBackup2.IsChecked = $false
    $ongr3.IsChecked = $false
    $RecycleBin3.IsChecked = $true
	$isBackup3.IsChecked = $false
    $ongr4.IsChecked = $false
    $RecycleBin4.IsChecked = $true
	$isBackup4.IsChecked = $false
    $ongr5.IsChecked = $false
    $RecycleBin5.IsChecked = $true
	$isBackup5.IsChecked = $false
    $autoStart.IsChecked = $false

    # Lấy giá trị của các biến từ registry
    $folder1.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder1")
    $folder2.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder2")
    $rptime.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "rptime")
    $BackupPath.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "BackupPath")
    $folder3.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder3")
    $folder4.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder4")
    $BackupPath2.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "BackupPath2")
    $folder5.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder5")
    $folder6.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder6")
    $BackupPath3.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "BackupPath3")
    $folder7.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder7")
    $folder8.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder8")
    $BackupPath4.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "BackupPath4")
    $folder9.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder9")
    $folder10.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "folder10")
    $BackupPath5.Text = (Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "BackupPath5")

	# Lấy giá trị từ registry và kiểm tra xem nó có phải là true hay không
	$RecycleBinValue = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "RecycleBin"
	$BackupValue = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "isBackup"
	$autosynValue = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "autosyn"
    $moreValue = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "more"
    $ongr2Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "ongr2"
    $RecycleBin2Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "RecycleBin2"
	$Backup2Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "isBackup2"
    $ongr3Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "ongr3"
    $RecycleBin3Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "RecycleBin3"
	$Backup3Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "isBackup3"
    $ongr4Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "ongr4"
    $RecycleBin4Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "RecycleBin4"
	$Backup4Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "isBackup4"
    $ongr5Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "ongr5"
    $RecycleBin5Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "RecycleBin5"
	$Backup5Value = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "isBackup5"
    $autoStartValue = Get-ItemPropertyValue -Path "HKCU:\Software\SaoLuuMini" -Name "autoStart"

	if ($RecycleBinValue -eq $false) {
		$RecycleBin.IsChecked = $false
	}
	if ($BackupValue -eq $true) {
		$isBackup.IsChecked = $true
	}
    if ($autoStartValue -eq $true) {
		$autoStart.IsChecked = $true
	}
	if ($autosynValue -eq $true) {
		$autosyn.IsChecked = $true
        $autosyn.Content = "Tự chạy [Bật]"
	}
    if ($moreValue -eq $true) {
		$syncMore.IsChecked = $true
	}
    if ($RecycleBin2Value -eq $false) {
		$RecycleBin2.IsChecked = $false
	}
    if ($RecycleBin3Value -eq $false) {
		$RecycleBin3.IsChecked = $false
	}
    if ($RecycleBin4Value -eq $false) {
		$RecycleBin4.IsChecked = $false
	}
    if ($RecycleBin5Value -eq $false) {
		$RecycleBin5.IsChecked = $false
	}
    if ($ongr2Value -eq $true) {
		$ongr2.IsChecked = $true
	}
    if ($ongr3Value -eq $true) {
		$ongr3.IsChecked = $true
	}
    if ($ongr4Value -eq $true) {
		$ongr4.IsChecked = $true
	}
    if ($ongr5Value -eq $true) {
		$ongr5.IsChecked = $true
	}
    if ($Backup2Value -eq $true) {
		$isBackup2.IsChecked = $true
	}
    if ($Backup3Value -eq $true) {
		$isBackup3.IsChecked = $true
	}
    if ($Backup4Value -eq $true) {
		$isBackup4.IsChecked = $true
	}
    if ($Backup5Value -eq $true) {
		$isBackup5.IsChecked = $true
	}
}

# Mỗi lần phần mềm được mở, nếu thấy autoStart đang được chọn thì đăng ký lại vào Registry, đề phòng file exe đã thay đổi sang đường dẫn mới
if ($autoStart.IsChecked) {
    Is_Startup -On $true
}

$autoStart.Add_Checked({
    Is_Startup -On $true
})

$autoStart.Add_Unchecked({
	Is_Startup -On $false
})

$isLog.Add_Checked({
    $window.Height = 600
    $window.MinHeight = 600
    $window.MaxHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight
	$logBox.Foreground = [System.Windows.Media.Brushes]::White
	$logBox.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(1, 36, 86))
    $rowDef3.Height = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)
})

# Khi window thu nhỏ, bên dưới sẽ tạo một khoảng màu đen, khoảng này sẽ biến mất nếu dịch chuyển window hoặc thay đổi kích thước lần nữa. Bởi vậy dùng mẹo: đặt window height là lệnh thực hiện sau cùng để thay đổi kích thước về 210.
$isLog.Add_Unchecked({
	$rowDef3.Height = New-Object System.Windows.GridLength(0)
    $window.MaxHeight = 210
    $window.MinHeight = 210
	$window.Height = 210
})

$syncMore.Add_Checked({
    $isLog.IsChecked = $false
    $isLog.IsEnabled = $false
    $canvas1.Visibility = 'Visible'
    $window.Height = 500
    $window.MinHeight = 500
    $window.MaxHeight = 500
    $rowDef1.Height = New-Object System.Windows.GridLength(290)
})

$syncMore.Add_Unchecked({
    $isLog.IsEnabled = $true
    $canvas1.Visibility = 'Hidden'
    $window.MaxHeight = 210
    $window.MinHeight = 210
	$window.Height = 210
    $rowDef1.Height = New-Object System.Windows.GridLength(0)
})

if ($syncMore.IsChecked) {
    $isLog.IsChecked = $false
    $isLog.IsEnabled = $false
    $canvas1.Visibility = 'Visible'
    $window.Height = 500
    $window.MinHeight = 500
    $window.MaxHeight = 500
    $rowDef1.Height = New-Object System.Windows.GridLength(290)
}

# Đồng bộ ngay nếu autosyn đang được kích hoạt
if ($autosyn.IsChecked) {
    [int]$tm = $rptime.Text
    Start-Sync -f1 $folder1.Text -f2 $folder2.Text -rb $RecycleBin.IsChecked -isb $isBackup.IsChecked -bu $BackupPath.Text -isl $isLog.IsChecked -tm $tm -logBox $logBox -on2 $ongr2.IsChecked -f3 $folder3.Text -f4 $folder4.Text -rb2 $RecycleBin2.IsChecked -isb2 $isBackup2.IsChecked -bu2 $BackupPath2.Text -on3 $ongr3.IsChecked -f5 $folder5.Text -f6 $folder6.Text -rb3 $RecycleBin3.IsChecked -isb3 $isBackup3.IsChecked -bu3 $BackupPath3.Text -on4 $ongr4.IsChecked -f7 $folder7.Text -f8 $folder8.Text -rb4 $RecycleBin4.IsChecked -isb4 $isBackup4.IsChecked -bu4 $BackupPath4.Text -on5 $ongr5.IsChecked -f9 $folder9.Text -f10 $folder10.Text -rb5 $RecycleBin5.IsChecked -isb5 $isBackup5.IsChecked -bu5 $BackupPath5.Text -more $syncMore.IsChecked
}

# Xử lý sự kiện nút
$run.Add_Click({
    [int]$tm = $rptime.Text
    Start-Sync -f1 $folder1.Text -f2 $folder2.Text -rb $RecycleBin.IsChecked -isb $isBackup.IsChecked -bu $BackupPath.Text -isl $isLog.IsChecked -tm $tm -logBox $logBox -on2 $ongr2.IsChecked -f3 $folder3.Text -f4 $folder4.Text -rb2 $RecycleBin2.IsChecked -isb2 $isBackup2.IsChecked -bu2 $BackupPath2.Text -on3 $ongr3.IsChecked -f5 $folder5.Text -f6 $folder6.Text -rb3 $RecycleBin3.IsChecked -isb3 $isBackup3.IsChecked -bu3 $BackupPath3.Text -on4 $ongr4.IsChecked -f7 $folder7.Text -f8 $folder8.Text -rb4 $RecycleBin4.IsChecked -isb4 $isBackup4.IsChecked -bu4 $BackupPath4.Text -on5 $ongr5.IsChecked -f9 $folder9.Text -f10 $folder10.Text -rb5 $RecycleBin5.IsChecked -isb5 $isBackup5.IsChecked -bu5 $BackupPath5.Text -more $syncMore.IsChecked
})

$stop.Add_Click({
    Stop-Sync
})

# Định nghĩa sự kiện cho nút "Hide"
$hidebar.Add_Click({
    $window.WindowState = 'Minimized'
    $window.ShowInTaskbar = $false
})

function Open-Guide {
    # Tạo cửa sổ WPF con
    $guideWindow = New-Object Windows.Window
    $guideWindow.Title = "Hướng dẫn"
    $guideWindow.Width = 800
    $guideWindow.Height = 600
    $guideWindow.ResizeMode = "NoResize"
    $guideWindow.WindowStartupLocation = "CenterOwner"
    $guideWindow.FontSize = 13
    $guideWindow.Icon = $bitmapSource
    # Đặt cửa sổ mẹ làm chủ của cửa sổ con
    $guideWindow.Owner = $window  

    $guideBox = New-Object Windows.Controls.TextBox
    $guideBox.Text = $txtGuide
    $guideBox.TextWrapping = "Wrap"
    $guideBox.VerticalScrollBarVisibility = "Auto"
    $guideBox.IsReadOnly = $true
    $guideWindow.Content = $guideBox

    # Hiển thị cửa sổ con và chờ đợi đóng
    $guideWindow.ShowDialog() | Out-Null
}

$guide.Add_Click({
    Open-Guide
})

# Xử lý sự kiện Closed của cửa sổ để dọn dẹp notifyIcon
# Thêm Dispatcher.InvokeShutdown() trong sự kiện Closed. Điều này sẽ đảm bảo rằng tất cả các công việc liên quan đến giao diện người dùng sẽ được hoàn thành trước khi thoát.
# Gọi [System.Environment]::Exit(0) sau khi dọn dẹp. Điều này sẽ dừng toàn bộ quá trình và dọn dẹp mọi tài nguyên đang được sử dụng bởi chương trình.
# Sử dụng [System.Windows.Application]::Current.Run($window) để chạy ứng dụng. Điều này đảm bảo rằng ứng dụng WPF sẽ chạy và xử lý các sự kiện đúng cách.
# Những thay đổi này sẽ đảm bảo rằng khi đóng cửa sổ WPF, chương trình sẽ thoát hoàn toàn và dọn dẹp mọi tài nguyên, không để lại bất kỳ tiến trình nào chạy trong Task Manager.
$window.add_Closed({
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
    $icon.Dispose()
    [System.Windows.Application]::Current.Dispatcher.InvokeShutdown()
    Start-Sleep -Milliseconds 100
    [System.Environment]::Exit(0)
})

# Hiển thị cửa sổ WPF
$app.Run($window)
