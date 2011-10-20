# redmine-deploy

Capistrano recipes for [Redmine](http://redmine.org) deployment. Setup is not fully automated,
though I try to minimize manual steps.

Current Redmine version is 1.2.1.

## Usage

1. This script tuned for multistaging deployment. Two stages defined:
   staging and production. Default stage is staging. You can change this in
   `config/deploy.rb#2`.

2. Redmine requires Ruby 1.8.7. I decided to use latest [REE](http://www.rubyenterpriseedition.com/)
   release. Install it on server using [RVM](http://beginrescueend.com/).
   Also gemset named `redmine` should be created. You can change these
   settings in `config/deploy.rb#15`. Another requirement is using rubygems
   1.6.2. This can be done by using `rvm rubygems 1.6.2` in previously
   created gemset.

3. Describe stages configuration. Use `config/deploy/stage.rb.example` as
   example. Stage description should be placed to `config/deploy`
   directory.

4. Configuration files will be automatically uploaded and symlinked
   during deployment process. Three configuration files should be
   created. First describes database connection settings (`confing/database.yml`),
   second - redmine configuration (`config/configuration.yml`), third -
   thin options (`config/thin.yml`). Add stage name extension to each
   file, so `database.yml` should be named `database.yml.production` for
   production environment.

5. `bundle exec cap deploy:setup`

6. `bundle exec cap deploy`

7. ...

8. Profit!

## Contribution

Ask question, submit pull request, enjoy!

## Authors

Dmitry Maksimov (dmtmax@gmail.com)
