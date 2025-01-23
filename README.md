# RISC OS Open Collaboa bug management fork

This is a Ruby On Rails 7+ fork of Collaboa, providing bug management facilities. For some historical context, please see:

* https://rubyonrails.org/2004/12/29/collaboa-and-elitejournal-joins-the-trac
* https://web.archive.org/web/20071013121944/http://www.collaboa.org/

The application was built by starting with a new Rails 7 application shell, then copying over and modifying files from the original Collaboa code. This rewrite is specifically focused on the [RISC OS Open (ROOL)](https://www.riscosopen.org/) web site's use of Collaboa, primarily on what ROOL refer to as the Epsilon server (or later).

The ROOL fork is based on whatever version was in use by ROOL on the old web site at the time the fork was constructed. There may have been later additions to the original software that were not merged into to the old ROOL code base and, if so, those additions will not be present here either.

## Old `README`

Since there no longer seems to be an easily accessible copy of the original code online, the original plain text `README` contents are included below - although of course, it is now outdated.

```
                                  Welcome to Collaboa
                                =======================

  CONTENTS
  --------
  1. About
  2. Requirements
  3. Installation & Upgrading
  4. Running tests
  5. Authors
  6. Acknowledgments


1. About
--------

The goal of Collaboa is to be a collaborative tool for developers using Subversion.

Currently, only the following features are available:
* Repository browsing
* Changeset viewer
* Issue tracking
* Milestone management

Thanks to Rails, the underlying framework, it runs on a number of web servers
supporting both FastCGI and plain CGI. Because of the speed improvements over plain
CGI, FastCGI is the preferred environment to run it in. The developer is known to
have a personal taste for "Lighttpd":http://lighttpd.net as a web server, but that
shouldn't stop you from using anything else, like Apache.

Some of the features planned for future releases are:
* Continuous integration of tests/builds

### A little background...

Colloboa has been heavily influenced by "Trac":http://projects.edgewall.com/trac/,
which showed the world how nicely version and bug tracking could be integrated.
Hopefully Colloboa still has a place in the world because of its different feature
set (although it may not be quite there yet).


You can find more info on http://collaboa.org along with official releases.
If you want to report a bug or submit a patch (both greatly appreciated) you can
visit the "Collaboa for Collaboa" at http://dev.collaboa.org


2. Requirements
---------------

Subversion 1.2.x with the Ruby SWIG bindings installed (see "Install" below)
Rails 1.0+


3. Install
----------

Please see INSTALL & UPGRADE


4. Running tests
----------------
The unit and functional tests expect the svn dump located in
./lib/actionsubversion/test/fixtures/data_for_tests.svn to be loaded in the repository located
at the path you've specified under "test" in the collaboa-config.yml. You can load it with the
following commands (REPOS_PATH being where you want the test repos):
$ svnadmin create REPOS_PATH
$ cat ./lib/actionsubversion/test/fixtures/data_for_tests.svn | svnadmin load REPOS_PATH

5. Authors
----------

Collaboa is maintained and developed by Johan Sørensen. You can find out more about him
at http://johansorensen.com/ or read his blog at http://theexciter.com. You can also send
an email to johan at johansorensen.com.

Contributions has been made by the following people:
* Jean-Philippe Bougi


6. Acknowledgments
-------------------
Collaboa contains a few shamefully lifted codesnippets from the Bugtrack application made by
Kent Sibilev. Specifically things related to creating TicketChange logs. You can find out more
about Kent's excellent bugtracker at http://rubyforge.org/projects/bugtrack
```
