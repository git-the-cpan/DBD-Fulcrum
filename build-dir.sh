#!/bin/ksh
# This is not related to DBD::Fulcrum.
# It creates an usable directory for Fulcrum tables, by copying needed files
# from fulcrum home.
# 
# build-dir $FULCRUM_HOME destionation-directory (must already exist)

cp $1/fultext/fultext.eft $2
cp $1/fultext/fultext.ftc $2
if [ -f $1/fultext/ftpdf.ini ];
then
	cp $1/fultext/ftpdf.ini $2
fi
cp $1/fultext/*mess $2

