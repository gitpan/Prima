#
#  Created by Dmitry Karasik  <dmitry@karasik.eu.org>
#
# $Id: noARGV.pm,v 1.1 2007/08/17 20:19:38 dk Exp $
#
# Initializes Prima so that it skips parsing @ARGV;

push @Prima::preload, 'noargv';
1;
