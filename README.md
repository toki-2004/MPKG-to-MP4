# MPKG to MP4

把 Wallpaper Engine 的 `.mpkg` 封包解包，直接提取出里面的 `wallpaper.mp4` 视频文件。

纯 Python 标准库实现，**不需要安装任何第三方依赖**，也不需要 ffmpeg 就能完成提取。

## 背景

Wallpaper Engine 创意工坊的壁纸下载后是 `.pkg` / `.mpkg` 封包，文件头是 `PKGM0014`。
它并不是一种视频格式，而是一个自定义容器：里面装着 `wallpaper.mp4`（视频本体）、
`project.json`、`scene.json`（壁纸配置）和 `preview.gif`（预览图）。

所以"转成 mp4"本质上不是转码，而是**把封包里的 mp4 提取出来**。

### 封包格式（供参考）

| 字段 | 长度 | 说明 |
| --- | --- | --- |
| 魔数 | 8 字节 | `08 00 00 00` + `PKGM0014` |
| 文件数量 | 4 字节 | 小端 uint32，例如 `04` 表示 4 个文件 |
| 文件条目 × N | 变长 | `名称长度(4) + 名称 + 偏移量(4) + 大小(4)`，偏移相对数据区起点 |
| 数据区 | 变长 | 按条目顺序连续存放各文件的数据 |

## 使用方法

### 方式一：拖拽（Windows）

1. 双击运行 `run.bat`。
2. 把 `.mpkg` 文件拖到黑色窗口上，回车。
3. 提取结果输出到封包旁边的 `<封包名>_extracted` 文件夹。

### 方式二：命令行

```bat
python extract.py "D:\path\to\package.mpkg"
```

也可以指定输出目录：

```bat
python extract.py "D:\path\to\package.mpkg" "D:\output"
```

提取后，输出目录里除了原始文件（`wallpaper.mp4`、`project.json`、`scene.json`、
`preview.gif`），还会额外复制一份 `封包名.mp4` 方便直接使用。

## ffmpeg 有用吗？

提取这一步**不需要** ffmpeg。不过如果你有 ffmpeg，可以：

- 验证视频是否完整：`ffprobe -v error -show_entries format=duration,size output.mp4`
- 重新压缩成更小的文件，例如压到 1080p：

```bat
ffmpeg -i output.mp4 -vf scale=-2:1080 -c:v libx264 -crf 23 -c:a copy output_1080p.mp4
```

## 环境要求

- Python 3.8+（仅使用标准库）
- Windows / macOS / Linux 均可运行；`run.bat` 仅适用于 Windows

## 常见问题

**提示"不是有效的 Wallpaper Engine 封包"？**
文件头不是 `PKGM0014`，可能不是本工具支持的封包格式，或文件已损坏。

**提取出的 mp4 很大怎么办？**
4K / 60fps 的壁纸视频通常有几十 MB，这是正常的。可以用 ffmpeg 重新压缩（见上文）。
