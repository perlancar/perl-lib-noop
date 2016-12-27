package lib::noop;

# DATE
# VERSION

use strict;
use warnings;

our @mods;
our $noop_code = "1;\n";

our $hook = sub {
    my ($self, $file) = @_;

    my $mod = $file; $mod =~ s/\.pm\z//; $mod =~ s!/!::!g;

    # decline if not in list of module to noop
    return undef unless grep { $_ eq $mod } @mods;

    return \$noop_code;
};

sub import {
    my $class = shift;

    @mods = @_;

    @INC = ($hook, grep { $_ ne "$hook" } @INC);
}

sub unimport {
    return unless $hook;
    @mods = ();
    @INC = grep { "$_" ne "$hook" } @INC;
}

1;
# ABSTRACT: no-op loading some modules

=for Pod::Coverage .+

=head1 SYNOPSIS

 use lib::noop qw(Foo::Bar Baz);
 use Foo::Bar; # now a no-op
 use Qux; # load as usual


=head1 DESCRIPTION

Given a list of module names, it will make subsequent loading of those modules a
no-op. This pragma can be used for testing. It works by installing a require
hook in C<@INC> that looks for the specified modules to be no-op'ed and return
"1;" as the source code for those modules.

=cut
