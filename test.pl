#!/usr/local/bin/perl -w
# Test script for DBD::Fulcrum
# $Revision: 1.2 $

use Carp;


BEGIN {

   if (length($ENV{'FULCRUM_HOME'}) <= 0) {
      $ENV{'FULCRUM_HOME'} = "/home/fulcrum";
      warn "FULCRUM_HOME set to /home/fulcrum!";
   }
   $ENV{'FULSEARCH'} = "./fultest" if (!defined($ENV{FULSEARCH}));
   $ENV{'FULTEMP'} = "./fultest" if (!defined($ENV{FULTEMP}));
}


# Base DBD Driver Test

print "Testing 'require DBI'...";

require DBI;
print "ok\n";

print "Testing 'import DBI'...";
import DBI;
print "ok\n";

#$DBI::dbi_debug=9;

###############
# Connect to fulcrum (or explode)
##############



my $ful_drh; 

print "Installing driver...";
if (!($ful_drh = DBI->install_driver ('Fulcrum'))) {
    print "FAILED: Cannot install Fulcrum driver ($DBI::errstr)\n";
    exit 1;
}

print "ok.\nDBD::Fulcrum driver version: $ful_drh->{Version}\n";

print "In order to execute the following tests, you MUST have created a table for us to test on.\n";
print "If you haven't already, answer N here and then follow the instructions: ";
$char = getc(STDIN);
if (lc($char) eq 'n') {
   print "\tSet FULCREATE, FULSEARCH and FULTEMP to appropriate values, then\n";
   print "\tcreate the table test using the script test.fte:\n";
   print "\texecsql -0 test.fte\n";
   print "\tHint: if you are creating a brand-new directory for this, remember\n";
   print "\tto copy over fultext.ftc, fultext.eft, ftpdf.ini (only 3.5) and \*mess files from $ENV{'FULCRUM_HOME'}/fultext\n";
   print "Testing aborted.\n";
   exit 0;
}


$::ful_dbh = undef; # global to avoid parameter passing...

print "Connecting to fulcrum (this is a no op)... ";
if (!($::ful_dbh = $ful_drh->connect ('','',''))) {
    print "Cannot connect to Fulcrum ($DBI::errstr)\n";
    exit 1;
}

print "ok.\n";

print "Setting SHOW_MATCHES to EXTERNAL_COLUMN... ";
if (!($::ful_dbh->do( "set show_matches 'EXTERNAL_COLUMN'"))) {
    print "FAILED: Cannot customize Fulcrum show_matches ($DBI::errstr)\n";
    exit 1;
}

print "ok\n";

print "Setting character set to ISO_LATIN1... ";
if (!($::ful_dbh->do( "set character_set 'ISO_LATIN1'"))) {
    print "FAILED: Cannot customize Fulcrum character_set ($DBI::errstr)\n";
    exit 1;
}

print "ok\n";

print "Inserting a document into test table... ";

@statdata = stat ('test.fte');
my $pwd = `pwd`;
chomp($pwd);

if (!($::ful_dbh->do(
		     "insert into test(title,filesize,ft_sfname) values ('Test document', $statdata[7], '$pwd/test.fte')"
		    ))) {
    print "FAILED: Cannot insert test.fte ($DBI::errstr)\n";
    exit 1;
}

print "ok\n";

print "Rebuilding index... ";
if (!($::ful_dbh->do( "VALIDATE INDEX test VALIDATE TABLE"))) {
   print "FAILED: Cannot rebuild index ($DBI::errstr)\n";
}

print "ok\n";
print "Now reading the text back (open)... ";

my $cursor = $::ful_dbh->prepare ('select ft_text,ft_sfname,filesize from test');

if ($cursor) {
   print "(execute) ... ";
   $cursor->execute;
   print "ok, now fetching (fetchrow):\n***\n";
   my $text;
   my @row;
   my $eot;
   while (@row  = $cursor->fetchrow) {
      $cursor->blob_read (1, 0, 8192, \$text);
      #or (print "+++ RB NOT OK:$DBI::errstr\n");
      $text = $` if ($text =~ /\x00/);
      print "(FILE: $row[1]) $text";
   }
   print "\n***\n\tok\n";
}
else {
   print "FAILED: Prepare failed ($DBI::errstr)\n";
   exit 1;
}

print "Exiting (NEVER use disconnect, at least with this release): OK\n";


exit 0;
# end.

