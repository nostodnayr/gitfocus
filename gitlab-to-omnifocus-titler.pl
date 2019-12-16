#!/usr/bin/env perl

my $page_title = shift;

$page_title =~ /(.+?) \((\W\d+)\)/ig;

my $ticket_title = $1;
my $ticket_number = $2;

if ($1 and $2) {
    my $action_title = "resolve ❮$ticket_number❯ – ‘$ticket_title’";
    print $action_title;
}
else {
    print "ERROR";
}
