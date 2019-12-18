#!/usr/bin/env perl

# GitFocus Helper Script
# gitfocus-titler.pl
# 
# By Ryan Dotson
# 18 December 2019
#
# This script is called by the GitFocus AppleScript
# and is responsible for returning the action title based on
# the GitLab/GitHub page title.
#
# You can customise the title by editing line 30 below, which
# is, by default:
#
#     print "resolve ❮$2❯ – ‘$1’";
#
# Where, as explained below, $2 is the ticket number and
# $1 is the ticket title.

my $page_title = shift;

# Match the page title against this regular expression
# which has groups for two items:
$page_title =~ /
                (.+?)\s       # title ($1)
                              # and
                \(?
                (\W\d+)       # ticket number ($2)
                \)?           # parentheses are optional: GitHub
                /igx;


# If both title and ticket number are matched, output the title.
if ($1 and $2) {
    print "resolve ❮$2❯ – ‘$1’";
}

# Otherwise output the string that the AppleScript expects.
else {
    print "**NOT MATCHED**";
}
