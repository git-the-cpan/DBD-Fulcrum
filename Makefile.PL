#!/usr/local/bin/perl -sw

use ExtUtils::MakeMaker;
use FileHandle;
#use ExtUtils::MakeMaker qw(&WriteMakefile $Verbose %att);
use Getopt::Std;
use Config;
use Carp;

$SIG{'__WARN__'} = sub { Carp::carp $_[0] };
$SIG{'__DIE__'}  = sub { Carp::confess $_[0] };
			   
require 'flush.pl';

use DBI;	# The DBI must be installed before we can build a DBD

getopts('g') or die "Invalid arguments";

$opt_g &&= '-g';

%::opts = (
	   NAME    => 'DBD::Fulcrum',
	   VERSION_FROM => 'Fulcrum.pm',
	   OPTIMIZE => $::opt_g,
	   dist => {
		   COMPRESS => 'gzip',
		   SUFFIX => '.gz'
		   }
	   );

# --- Introduction

print "\nConfiguring DBD::Fulcrum...\n";
print "Remember to actually read the CAVEATS file!\n\n";

# --- Where is Fulcrum SearchServer installed...

my $FULCRUM = $ENV{'FULCRUM_HOME'} || '/home/fulcrum';

print "Using Fulcrum in $FULCRUM\n";


# --- What FULCRUM is installed...


my $OCIINCLUDE = $::MK{INCLUDE} || "-I$FULCRUM/include";




# Would this be the default? We'll se with Solaris (next in line)
my $sysliblist ="-L$FULCRUM/lib -lftft -lftet -lm";
$::opts{INC}  = "$OCIINCLUDE -I\$(INSTALLSITEARCH)/auto/DBI";
# type of linking and libs (begin)
if ($::Config{osname} eq 'dec_osf') {
    print "Warning: forced to build static not dynamic on $Config{osname} $Config{osver}\n";
    print "Warning: You need to hand-edit Makefile.aperl and change MAP_LINKCMD to read = $(CC) -taso ...\n";
    print "         See README and Makefile.PL for more information.\n";
    $opts{LINKTYPE} = 'static';
    $opts{DEFINE} = '-taso';
}
else {
    $opts{dynamic_lib} = { OTHERLDFLAGS => '$(COMPOBJS) ' };
}

if ($Config{osname} eq 'aix') {
   $::opts{OBJECT} = '$(O_FILES)' . " $FULCRUM/lib/libftft.\*.o $FULCRUM/lib/libftet.\*.o";
   $sysliblist = ''; # sorry, not like this...
   $opts{DEFINE} .= ' -qsrcmsg';
}
else {
   $opts{OBJECT} = '$(O_FILES)';
}

$::opts{LIBS} = [ $sysliblist ];


# log key platform information to help me help you quickly


print "FULCRUM sysliblist (may be empty if .o are needed) on this platform:\n";
print "\t$sysliblist\n";

print "System: perl$] @Config{qw(myuname archname dlsrc)}\n";
print "Compiler: @Config{qw(cc optimize ccflags)}\n";
print "  CC:       $MK{CC}\n"		if $MK{CC};
print "  CFLAGS:   $MK{CFLAGS}\n"	if $MK{CFLAGS};
print "  LDFLAGS:  $MK{LDFLAGS}\n"	if $MK{LDFLAGS};
print "  LDSTRING: $MK{LDSTRING}\n"	if $MK{LDSTRING};

print "\n";

WriteMakefile(%opts);

exit 0;


sub ask {
    my($prompt, $default) = @_;
	printflush(STDOUT,"$prompt: ");
	printflush(STDOUT,"[$default] ") if $default;
    my $value = <>;
	chomp $value;
	return $value or $default;
}
