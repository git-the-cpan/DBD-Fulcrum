#
#	Project		: DBD::Fulcrum
#	Module/Library	: 
#	Author		: $Author: root $
#	Revision	: $Revision: 1.6 $
#	Check-in date	: $Date: 1997/05/19 07:57:09 $
#	Locked by	: $Locker:  $
#
#	----------------
#	Copyright	:
#	$Id: Fulcrum.pm,v 1.6 1997/05/19 07:57:09 root Exp $ (c) 1996, Inferentia (Milano) IT
#	
#	Description	:

{
    package DBD::Fulcrum;

    use DBI;

    use DynaLoader;
    @ISA = qw(Exporter DynaLoader);
	
	@EXPORT_OK = qw($attrib_int $attrib_char $attrib_float 
				 $attrib_date $attrib_ts $attrib_dec
				 $attrib_ts_nullok $attrib_int_nullok $attrib_char_nullok);
    
    $VERSION = '0.09';
    
    my $revision = substr(q$Revision: 1.6 $, 10);
    require_version DBI 0.81 ;

    bootstrap DBD::Fulcrum;

    #use Fulcrum::Constants;

    $err = 0;		# holds error code   for DBI::err
    $errstr = "";	# holds error string for DBI::errstr
    $drh = undef;	# holds driver handle once initialised

    $attrib_dec = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
                    'Stype' => SQL_DECIMAL,
                    'Prec'  => 31,
                    'Scale' => 4,
                  };
    $attrib_int = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
                    'Stype' => SQL_INTEGER,
                    'Prec'  => 10,
                    'Scale' => 4,
                  };
    $attrib_int_nullok = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
					'Snullok' => 1,
                    'Stype' => SQL_INTEGER,
                    'Prec'  => 10,
                    'Scale' => 4,
                  };
    $attrib_char = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
                    'Stype' => SQL_CHAR,
                    'Prec'  => 254,
                    'Scale' => 0,
                  };
    $attrib_char_nullok = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
					'Snullok' => 1,
                    'Stype' => SQL_CHAR,
                    'Prec'  => 254,
                    'Scale' => 0,
                  };
#	print "<",$attrib_char->{'Ctype'},">\n";
    $attrib_float = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
                    'Stype' => SQL_FLOAT,
                    'Prec'  => 15,
                    'Scale' => 6,
                  };
    $attrib_date = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
                    'Stype' => SQL_DATE,
                    'Prec'  => 10,
                    'Scale' => 9,
                  };
    $attrib_ts = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
                    'Stype' => SQL_TIMESTAMP,
                    'Prec'  => 26,
                    'Scale' => 11,
                  };
    $attrib_ts_nullok = { 'ParamT' => SQL_PARAM_INPUT,
                    'Ctype' => SQL_C_CHAR,
					'Snullok' => 1,
                    'Stype' => SQL_TIMESTAMP,
                    'Prec'  => 26,
                    'Scale' => 11,
					};
 
    sub driver{
	return $drh if $drh;
	my($class, $attr) = @_;

	unless ($ENV{'FULCRUM_HOME'}){
		$ENV{'FULCRUM_HOME'} = "/home/fulcrum";
	    my $msg = "set to $ENV{'FULCRUM_HOME'}"; 
	    warn "FULCRUM_HOME $msg\n";
	}

	$class .= "::dr";

	# not a 'my' since we use it above to prevent multiple drivers

	$drh = DBI::_new_drh($class, {
	    'Name' => 'Fulcrum',
	    'Version' => $VERSION,
	    'Err'    => \$DBD::Fulcrum::err,
	    'Errstr' => \$DBD::Fulcrum::errstr,
	    'Attribution' => 'Fulcrum SearchServer DBD by Davide Migliavacca',
	    });

	$drh;
    }

    1;
}


{   package DBD::Fulcrum::dr; # ====== DRIVER ======
    use strict;

    sub errstr {
	DBD::Fulcrum::errstr(@_);
    }

    sub connect {
	my($drh, $dbname, $user, $auth)= @_;

	if ($dbname){	# application is asking for specific database
	}

	# create a 'blank' dbh

	my $this = DBI::_new_dbh($drh, {
	    'Name' => $dbname,
	    'USER' => $user,
	    'CURRENT_USER' => $user,
	    });

	DBD::Fulcrum::db::_login($this, $dbname, $user, $auth)
	    or return undef;

	$this;
    }

}


{   package DBD::Fulcrum::db; # ====== DATABASE ======
    use strict;

    sub errstr {
	DBD::Fulcrum::errstr(@_);
    }

    sub prepare {
	my($dbh, $statement)= @_;

	# create a 'blank' dbh

	my $sth = DBI::_new_sth($dbh, {
	    'Statement' => $statement,
	    });

	DBD::Fulcrum::st::_prepare($sth, $statement)
	    or return undef;

	$sth;
    }

}


{   package DBD::Fulcrum::st; # ====== STATEMENT ======
    use strict;

    sub errstr {
	DBD::Fulcrum::errstr(@_);
    }

}

1;
