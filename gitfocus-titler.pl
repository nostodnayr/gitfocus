#!/usr/bin/env perl

# GitFocus Helper Script, Revision 2
# gitfocus-titler.pl
#
# By Ryan Dotson
# 12 January 2020
#
# This script is called by the GitFocus AppleScript
# and is responsible for returning the action title based on
# the GitLab/GitHub page title.
#
# You can customise the title by editing line 43 below, which
# is, by default:
#
#     print "resolve ❮$issue_number❯ – ‘$issue_title’";
#

use strict;

my ($page_title, $flavour) = @ARGV;
my ($issue_title, $issue_number);


# GitLab and GitHub have different page titles, so we need to
# determine the issue or MR number and title using different methods.
#
# Here, too, we will assume that the page comes from GitLab if it's
# not GitHub. We're also passed 'unknown' from the AppleScript in case
# we want to check explicitly in later versions.

if ($flavour eq "github") {
    ($issue_title, $issue_number) = $page_title =~ /(.+?) · (?:Issue|Merge Request) (\W\d+)/ig;
}
else {
    ($issue_title, $issue_number) = $page_title =~ /(.+?) \((\W\d+)\)/ig;
}


# If both title and ticket number are matched, output the title.
# Otherwise, print a string the AppleScript expects to tell it the
# script has failed to find the information.

if ($issue_title and $issue_number) {
    print "resolve ❮$issue_number❯ – ‘$issue_title’";
}
else {
    print "**NOT MATCHED**";
}
