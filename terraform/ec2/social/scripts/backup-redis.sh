#!/usr/bin/env bash

sudo aws s3 cp /var/lib/redis/dump.rdb s3://plemmons-social-backup/redis/dump.rdb-$(date "+%Y%m%dT%H%M%S")
