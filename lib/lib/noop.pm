package lib::noop;

# AUTHORITY
# DATE
# DIST
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
no-op. It works by installing a require hook in C<@INC> that looks for the
specified modules to be no-op'ed and return "1;" as the source code for those
modules.

This makes loading a no-op'ed module a success, even though the module does not
exist on the filesystem. And the C<%INC> entry for the module will be added,
making subsequent loading of the same module a no-op too because Perl's require
will see that the entry for the module in C<%INC> already exists.

But, since the loading is a no-op operation, no code other than "1;" is executed
and if the original module contains function or package variable definition,
they will not be defined.

This pragma can be used e.g. for testing.

To cancel the effect of lib::noop, you can unimport it. If you then want to
actually load a module that has been no-op'ed, you have to delete its C<%INC>
entry first:

 use lib::noop qw(Data::Dumper);
 use Data::Dumper;

 # this code will die because Data::Dumper::Dumper is not defined
 BEGIN { print Data::Dumper::Dumper([1,2,3]) }

 no lib::noop;
 BEGIN { delete $INC{"Data/Dumper.pm"} }
 use Data::Dumper;

 # this code now runs ok
 BEGIN { print Data::Dumper::Dumper([1,2,3]) }


=head1 SEE ALSO

L<lib::noop::all>

L<lib::noop::all_missing>

=cut
