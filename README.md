# MPKG to MP4

把 Wallpaper Engine 的 `.mpkg` 封包解包，直接提取出里面的 `wallpaper.mp4` 视频文件。

源码仅使用 Python 标准库，无第三方依赖；无需安装 Python 的用户可从
[Releases](https://github.com/toki-2004/MPKG-to-MP4/releases) 下载免安装版 `mpkg2mp4.exe`。

## 背景

Wallpaper Engine 的 `.mpkg` 封包，文件头是 `PKGM0014`。它并不是一种视频格式，
而是一个自定义容器：里面装着 `wallpaper.mp4`（视频本体）、
`project.json`、`scene.json`（壁纸配置）和 `preview.gif`（预览图）。

因此“转成 mp4”本质上并非转码，而是**从封包中提取其中的 mp4 文件**。

### 如何获取 .mpkg 文件

右键订阅的壁纸 → 发送至移动设备 → 导出 `.mpkg`，选择预渲染，相关设置可自行调整，即可获取该壁纸的 mpkg 文件。

### 封包格式（供参考）

| 字段 | 长度 | 说明 |
| --- | --- | --- |
| 魔数 | 8 字节 | `08 00 00 00` + `PKGM0014` |
| 文件数量 | 4 字节 | 小端 uint32，例如 `04` 表示 4 个文件 |
| 文件条目 × N | 变长 | `名称长度(4) + 名称 + 偏移量(4) + 大小(4)`，偏移相对数据区起点 |
| 数据区 | 变长 | 按条目顺序连续存放各文件的数据 |

## 使用方法

### 方式一：拖拽（Windows）

1. 双击运行 `run.bat`（本机需装有 Python）。

   若未安装 Python，可从 [Releases](https://github.com/toki-2004/MPKG-to-MP4/releases)
   下载免安装版 `mpkg2mp4.exe`：双击 exe 会直接打开交互窗口，把 `.mpkg` 文件拖入窗口
   回车即可提取；也可以把 `.mpkg` 文件拖到 exe 图标上，提取完成后按回车退出。
2. 窗口会出现 `mpkg path:` 输入提示，把 `.mpkg` 文件直接拖进窗口，回车。
3. 提取完成后可以继续拖入下一个文件；输入 `exit` 回车即可退出。
4. 提取结果输出到封包旁边的 `<封包名>_extracted` 文件夹。

也可以把 `.mpkg` 文件直接拖到 `run.bat` 图标上，处理完一个后自动退出。

### 方式二：命令行

```bat
python extract.py "D:\path\to\package.mpkg"
```

其中 `"D:\path\to\package.mpkg"` 仅为**示例路径**，需替换为实际 `.mpkg` 文件的位置。
例如，若文件位于 `D:\pythonitems\3590728775.mpkg`，则应运行：

```bat
python extract.py "D:\pythonitems\3590728775.mpkg"
```

若不清楚完整路径，可在文件资源管理器中找到该 `.mpkg` 文件，按住 Shift 键右键点击，
选择“复制文件地址”，再将复制内容粘贴至命令中。

也可以指定输出目录（最后一个参数是输出位置，不填则默认输出到封包旁边）：

```bat
python extract.py "D:\pythonitems\3590728775.mpkg" "D:\output"
```

提取完成后，输出目录中除原始文件（`wallpaper.mp4`、`project.json`、`scene.json`、
`preview.gif`）外，还会额外生成一份 `封包名.mp4`，便于直接使用。

## 环境要求

- Windows：`run.bat` 需要本机装有 Python；免安装版 `mpkg2mp4.exe` 可从
  [Releases](https://github.com/toki-2004/MPKG-to-MP4/releases) 下载
- 想从源码运行时需要 Python 3.8+（仅使用标准库），Windows / macOS / Linux 均可

### 从源码构建 exe（可选）

```bat
pip install pyinstaller
pyinstaller --onefile --console --name mpkg2mp4 extract.py
```

生成的 `dist\mpkg2mp4.exe` 即为免安装版本。

## 常见问题

**提示"不是有效的 Wallpaper Engine 封包"？**
文件头不是 `PKGM0014`，可能不是本工具支持的封包格式，或文件已损坏。

**提取出的 mp4 很大怎么办？**
4K / 60fps 的壁纸视频通常有几十 MB，这是正常的。
