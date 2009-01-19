#!/bin/sh

# set SVN mime property:

svn propset svn:mime-type 'application/xhtml+xml' t1.html 
svn propset svn:mime-type 'text/html' t2.html 
svn propset svn:mime-type 'application/xhtml+xml' t3.html 
svn propset svn:mime-type 'application/xhtml+xml' t4.html 
svn propset svn:mime-type 'application/xhtml+xml' t5.html 
svn propset svn:mime-type 'text/html' t6.html 
svn propset svn:mime-type 'application/xhtml+xml' t7.html 
svn propset svn:mime-type 'text/html' t8.html 
svn propset svn:mime-type 'application/xhtml+xml' g1.html 

svn commit -m 'updated mimetypes by script mime.sh' *.html

#g1.html:<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
#t1.html:<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
#t2.html:<!DOCTYPE HTML>
#t3.html:<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
#t4.html:<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
#t5.html:<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
#t6.html:<!DOCTYPE HTML>
#t7.html:<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
#t8.html:<!DOCTYPE HTML>

