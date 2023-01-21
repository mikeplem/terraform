#!/usr/bin/env bash
set -e

_backup_time=$(date "+%Y%m%dT%H%M%S")
sudo -u postgres -i pg_dump --dbname=mastadon --file="/tmp/mastadon.pgdump-${_backup_time}" --clean --create
if aws s3 cp "/tmp/mastadon.pgdump-${_backup_time}" "s3://plemmons-social-backup/postgres/db.pgdump-${_backup_time}"; then
    sudo -u postgres -i rm "/tmp/mastadon.pgdump-${_backup_time}"
fi
