#!/usr/bin/env bash

aws s3 cp /var/www/mastodon/.env.production s3://plemmons-social-backup/mastodon-env/env.production-$(date "+%Y%m%dT%H%M%S")
