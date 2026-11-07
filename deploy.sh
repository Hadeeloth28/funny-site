#!/bin/bash
# Downloads this site from GitHub with wget and serves it with Apache.
# Usage:  sudo bash deploy.sh GITHUB_USER REPO_NAME [BRANCH]
set -e

USER_NAME="$1"
REPO="$2"
BRANCH="${3:-main}"

if [ -z "$USER_NAME" ] || [ -z "$REPO" ]; then
  echo "Usage: sudo bash deploy.sh GITHUB_USER REPO_NAME [BRANCH]"
  exit 1
fi

apt-get update -y
apt-get install -y apache2 wget

# Download the whole repo as one archive
cd /tmp
rm -rf site site.tar.gz
wget -O site.tar.gz "https://github.com/$USER_NAME/$REPO/archive/refs/heads/$BRANCH.tar.gz"
mkdir site
tar -xzf site.tar.gz -C site --strip-components=1

# Replace Apache's default page with the site
rm -rf /var/www/html/*
cp -r site/index.html site/images /var/www/html/
chown -R www-data:www-data /var/www/html

systemctl enable apache2
systemctl restart apache2

echo "Done. Open http://<VM_EXTERNAL_IP>/ in your browser."
