#!/usr/bin/env bash

set -x

cp /vagrant/LocalSettings.php /var/www/mediawiki
chown www-data:www-data /var/www/mediawiki/LocalSettings.php
chmod 777 /var/www/mediawiki/LocalSettings.php

cd /vagrant
git clone https://gerrit.wikimedia.org/r/mediawiki/skins/Vector
cp -Rf Vector /var/www/mediawiki/skins/

exit 0
