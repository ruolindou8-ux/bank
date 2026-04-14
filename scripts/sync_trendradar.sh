#!/bin/bash

# 从 trendradar/output/ 同步 txt 文件到 bank/raw/
# 创建每日文件夹，按日期整理

TRENDRADAR_DIR="/home/admin/trendradar/output"
BANK_RAW_DIR="/home/admin/.openclaw/workspace/bank/raw"
LOG_FILE="/home/admin/.openclaw/workspace/bank/wiki/_meta/RAW_INGEST_LOG.md"

# 获取当天日期
TODAY=$(date +%Y年%m月%d日)
TODAY_SHORT=$(date +%Y-%m-%d)

echo "=== 开始同步 trendradar -> bank/raw ==="
echo "日期: $TODAY"

# 创建当天的输出目录
SOURCE_DIR="$TRENDRADAR_DIR/$TODAY/txt"
TARGET_DIR="$BANK_RAW_DIR/$TODAY"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源目录不存在: $SOURCE_DIR"
    exit 1
fi

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 同步文件（只复制新的或修改的文件）
count=0
for file in "$SOURCE_DIR"/*.txt; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        # 如果目标文件不存在或源文件更新，则复制
        if [ ! -f "$TARGET_DIR/$filename" ] || [ "$file" -nt "$TARGET_DIR/$filename" ]; then
            cp -n "$file" "$TARGET_DIR/"
            echo "同步: $filename"
            ((count++))
        fi
    fi
done

echo "=== 同步完成: $count 个文件 ==="

# 记录到日志
LOG_ENTRY="## $TODAY_SHORT 同步
- 来源: $SOURCE_DIR
- 同步文件数: $count
- 时间: $(date '+%Y-%m-%d %H:%M:%S')
"

echo "$LOG_ENTRY" >> "$LOG_FILE"
