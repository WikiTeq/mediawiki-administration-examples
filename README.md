# mediawiki-administration-examples

1. Clone this repository
2. Clone mediawiki into a `mediawiki` directory located in the same directory
as the files from this repository
3. In that `mediawiki` directory, check out the version of MediaWiki that you
want, and run `git submodule update --init --recursive`
4. Go back up one level in the file structure to the clone of this repository
5. Run `docker compose up -d`
6. Run `docker compose exec mediawiki bash`
7. In the container, start mysql by running `service mysql start`
8. In the container, start varnish by running `varnishd -f /etc/varnish/default.vcl`
9. In the container, start apache by running `apache2ctl start`
10. Visit the wiki at `http://localhost:80/wiki/`

The first time you launch the wiki, you also need to set it up
1. Go through the installation screens, using `127.0.0.1` as the database host
and `TheRootPassword` as the root database password
2. Download the resulting settings file and place it at
`mediawiki/LocalSettings.php`
