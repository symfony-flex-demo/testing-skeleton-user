#!/bin/sh
# [[ ]] requires bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

. install.env || true
printenv PACKAGE
if ! [[ -v PACKAGE ]]; then
  echo 'env PACKAGE=skeleton <this command>'
  echo 'or'
  echo 'env PACKAGE=website-skeleton <this command>'
  exit 1
fi

origin=$(pwd)
composer create-project --no-install symfony/$PACKAGE $CREATE_PROJECT_DIRECTORY
if [[ -v CREATE_PROJECT_DIRECTORY ]]; then
  cd $CREATE_PROJECT_DIRECTORY
else
  cd $PACKAGE
fi
pwd
(cd $origin/etap/install && tar --exclude-vcs --create --file - .) | tar --extract --verbose --file -
composer config bin-dir bin
# cp $origin/.env.dist . # Needs apparently to be done before install.

composer install
# composer require symfony/yaml # in symfony/skeleton
# composer require symfony/console # in symfony/skeleton
composer require twig # symfony/twig-bundle # in symfony/website-skeleton
composer require annotations # sensio/framework-extra-bundle # in symfony/website-skeleton
composer require orm-pack # symfony/orm-pack # in symfony/website-skeleton
composer require mailer # symfony/swiftmailer-bundle # in symfony/website-skeleton
# composer require symfony/security-csrf
# cp $origin/config/packages/*.yaml config/packages --verbose
# cp $origin/config/routes/*.yaml config/routes --verbose
composer require translation # symfony/translation for user-bundle DEBUG
(cd $origin/etap/fos_user && tar --exclude-vcs --create --file - .) | tar --extract --verbose --file -
composer require friendsofsymfony/user-bundle # :2.1.x-dev@dev
composer require --dev web-server # symfony/web-server-bundle
composer require --dev test-pack # symfony/test-pack

# cp $origin/src/Entity/*.php src/Entity --verbose # May be done earlier.
bin/console doctrine:database:create
bin/console doctrine:migrations:diff --quiet
bin/console doctrine:migrations:migrate --no-interaction --quiet
# bin/console doctrine:schema:update --force
# composer require doctrine/doctrine-fixtures-bundle --dev
# cp $origin/src/DataFixtures/AppFixtures.php src/DataFixtures
# bin/console doctrine:fixtures:load --append

bin/console assets:install --symlink
