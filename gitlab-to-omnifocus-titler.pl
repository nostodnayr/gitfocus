#!/usr/bin/env perl

# GitLab to OmniFocus Helper Script
# gitlab-to-omnifocus-titler.pl
# 
# By Ryan Dotson
# 18 December 2019
#
# This script is called by the 'GitLab to OmniFocus' AppleScript
# and is responsible for returning the action title based on
# the GitLab page title.
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
#
#      title ($1) ↓        ↓ ticket number ($2)
$page_title =~ /(.+?) \((\W\d+)\)/ig;


# If both are matched, output the title.
if ($1 and $2) {
    print "resolve ❮$2❯ – ‘$1’";
}

# Otherwise output the string that the AppleScript expects.
else {
    print "**NOT GITLAB**";
}
