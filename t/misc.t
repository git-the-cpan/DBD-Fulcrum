use Carp;
use DBI;
use DBD::Fulcrum;

BEGIN {
  $tests = 6;
  $ENV{FULSEARCH} = './fultest' if !defined($ENV{FULSEARCH});
  $ENV{FULTEMP} = './fultest' if !defined($ENV{FULTEMP});	
}

print "1..$tests\n";

my $dbh = DBI->connect('dbi:Fulcrum:','','');

print "ok 1\n" if defined($dbh);

my $cur;
$cur = $dbh->prepare('select title from test');

print "ok 2\n" if defined($cur);

$cur = $dbh->do('validate index test validate table');

print "ok 3\n" if defined($cur);

$dbh->disconnect();

print "ok 4\n";

$dbh = DBI->connect ('dbi:Fulcrum:','','');

print "ok 5\n" if $dbh;

print "$DBI::errstr\n" if (!$dbh->disconnect());

print "ok 6\n" if $dbh;

exit 0;
