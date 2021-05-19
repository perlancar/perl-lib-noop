package lib::noop::all;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

our $noop_code = "1;\n";

our $hook = sub {
    my ($self, $file) = @_;

    return \$noop_code;
};

sub import {
    my $class = shift;
    @INC = ($hook, grep { $_ ne "$hook" } @INC);
}

sub unimport {
    return unless $hook;
    @INC = grep { "$_" ne "$hook" } @INC;
}

1;
# ABSTRACT: no-op loading of all modules

=for Pod::Coverage .+

=head1 SYNOPSIS

 use lib::noop::all;
 use Foo::Bar; # now a no-op
 use Qux;      # ditto

On the command-line, checking script syntax without loading any module:

 % perl -Mlib::noop::all -c your-script.pl


=head1 DESCRIPTION

This pragma installs an C<@INC> handler that will no-op all your subsequent
module loading (via C<use> or C<require>). Instead of loading the module and
executing its code, Perl will be tricked to just executing C<"1;">.

This pragma can be used for testing or for "checking syntax while skipping
loading modules" in the simplistic cases.

Note that even though the loading is "no-op"-ed, the C<%INC> entry for the
module will still be added, making subsequent loading of the same module a truer
no-op because Perl's C<require()> will see that the entry for the module in
C<%INC> already exists.

Also note that since the loading becomes a no-op operation, and no code other
than C<"1;"> is executed during loading, if the original module contains
function or package variable definition, they obviously will not be defined and
your module-using code will be affected.

To cancel the effect of this pragma, you can unimport it. If you then want to
actually load a module that has been no-op'ed, you have to delete its C<%INC>
entry first:

 use lib::noop::all;
 use Data::Dumper;

 # this code will die because Data::Dumper::Dumper is not defined
 BEGIN { print Data::Dumper::Dumper([1,2,3]) }

 no lib::noop::all;
 BEGIN { delete $INC{"Data/Dumper.pm"} }
 use Data::Dumper;

 # this code now runs ok
 BEGIN { print Data::Dumper::Dumper([1,2,3]) }


=head1 SEE ALSO

L<lib::noop>

L<lib::noop::missing>

=cut
