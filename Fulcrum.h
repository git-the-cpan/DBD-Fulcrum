/*

  Project	: DBD::Fulcrum
  Module/Library:
  Author	: $Author: root $
  Revision	: $Revision: 1.1 $
  Check-in date	: $Date: 1997/06/18 13:53:48 $
  Locked by	: $Locker:  $

  RCS-id: $Id: Fulcrum.h,v 1.1 1997/06/18 13:53:48 root Exp $ (c) 1996, Inferentia S.r.l. (Milano) IT

  Description	: 

   You may distribute under the terms of either the GNU General Public
   License or the Artistic License, as specified in the Perl README
   file.

*/

#define NEED_DBIXS_VERSION 5

#include <DBIXS.h>		/* installed by the DBI module	*/

/* Fulcrum doesn't use these
   #include <sqlcli.h>
   #include <sqlcli1.h>
   */
#include <sqlc.h>
/* Mapping of ODBC to SQLCLI names (used in dbdimp.c) */
typedef HDBC SQLHDBC;
typedef HENV SQLHENV;
typedef HSTMT SQLHSTMT;
typedef UCHAR SQLCHAR;
typedef SDWORD SQLINTEGER;
typedef SWORD SQLSMALLINT;



/* read in our implementation details */

#include "dbdimp.h"

void dbd_init _((dbistate_t *dbistate));

int  dbd_db_login _((SV *dbh, SQLCHAR *dbname, SQLCHAR *uid, SQLCHAR *pwd));
int  dbd_db_do _((SV *sv, SQLCHAR *statement));
int  dbd_db_commit _((SV *dbh));
int  dbd_db_rollback _((SV *dbh));
int  dbd_db_disconnect _((SV *dbh));
void dbd_db_destroy _((SV *dbh));
int  dbd_db_STORE _((SV *dbh, SV *keysv, SV *valuesv));
SV  *dbd_db_FETCH _((SV *dbh, SV *keysv));


int  dbd_st_prepare _((SV *sth, SQLCHAR *statement, SV *attribs));
int  dbd_st_rows _((SV *sv));
int  dbd_bind_ph _((SV *h, SV *param, SV *value, SV *attribs));
int  dbd_st_execute _((SV *sv));
AV  *dbd_st_fetch _((SV *sv));
int  dbd_st_finish _((SV *sth));
void dbd_st_destroy _((SV *sth));
int  dbd_st_blob_read _((SV *sth, int field, long offset, long len,
			SV *destrv, long destoffset));
int  dbd_st_STORE _((SV *dbh, SV *keysv, SV *valuesv));
SV  *dbd_st_FETCH _((SV *dbh, SV *keysv));


/* end of DB2.h */
