#!/bin/bash

# Define variables
BACKUP_DIR="/hdd/hkerp_backup"
HKERP_DIR="/home/hoangkhang/hkerp"
DATABASE_NAME="hkerp_production"
DUMP_FILE="$HKERP_DIR/data.dump"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ZIP_FILE="$BACKUP_DIR/${TIMESTAMP}_hkerp_production_db_source.zip"

# Remove old dump file if it exists
rm -f "$DUMP_FILE"

# Create a new database dump
pg_dump "$DATABASE_NAME" >> "$DUMP_FILE"

# Create a zip file with the current timestamp
zip -r "$ZIP_FILE" "$HKERP_DIR"/*

# Retain only the last 1 backup files and delete older ones
cd "$BACKUP_DIR"
ls -tp | grep -v '/$' | tail -n +2 | xargs -I {} rm -- {}
