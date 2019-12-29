#!/usr/bin/env perl

# GitFocus Helper Script
# gitfocus-sorter.pl
# 
# By Ryan Dotson
# 18 December 2019
#
# This script evaluates the web page title and will determine which
# project the resulting action should be sorted into.
#
# For the script to properly sort your action into a
# project (and not just open the quick entry window), you
# must edit this file.
#
# You can add as many projects as you need. Perl will
# 'print' the project name if the page title matches a regular
# expression (regex) search string. You don't need to understand
# regex to do this.
#
# If your GitLab/GitHub project were called
# content / web / support / en and you want to sort those items
# into an OmniFocus project called "Support Pages", you could
# use this:
#
#     print "Support Pages" if $page_title =~ m`content / web / support / en`;
#
# You might try using a search like m`support` but an action
# could be sorted incorrectly if the word 'support' appears
# elsewhere in the page title. It's better to be specific.
#
# Note that the backticks (`) around the search pattern
# are there to tie off the ends of the pattern. If your project
# happens to have a backtick in its name, you'll need to escape it
# using \` instead.

my $page_title = shift;

# Example:
#     print "OMNIFOCUS PROJECT NAME" if $page_title =~ m`SEARCH STRING`;

# Delete the example and add your projects below:
print "OMNIFOCUS PROJECT NAME" if $page_title =~ m`SEARCH STRING`;
