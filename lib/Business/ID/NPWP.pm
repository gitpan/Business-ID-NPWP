package Business::ID::NPWP;

use warnings;
use strict;
use DateTime;
require Exporter;
use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(validate_npwp);

=head1 NAME

Business::ID::NPWP - Validate Indonesian taxpayer registration number (NPWP)

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Business::ID::NPWP;
    
    # OO-style

    my $npwp = Business::ID::NPWP->new($str);
    die "Invalid NPWP!" unless $npwp->validate;

    print $npwp->taxpayer_code, "\n"; # also, kode_wajib_pajak()
    print $npwp->serial, "\n"; # also, nomor_urut()
    print $npwp->check_digit, "\n";
    print $npwp->local_tax_office_code, "\n"; # also, kode_kpp()
    print $npwp->branch_code, "\n"; # also, kode_cabang()

    # procedural style

    validate_npwp($str) or die "Invalid NPWP!";
    
=head1 DESCRIPTION

This module can be used to validate Indonesian taxpayer registration
number, Nomor Pokok Wajib Pajak (NPWP).

NPWP is composed of 15 digits as follow:

 ST.sss.sss.C-OOO.BBB

C<S> is a serial number from 0-9 (so far haven't seen 7 and up, but
it's probably possible).

C<T> denotes taxpayer type code (0 = government treasury [bendahara
pemerintah], 1-3 = company/organization [badan], 4/6 = invidual
entrepreneur [pengusaha perorangan], 5 = civil servants [pegawai
negeri, PNS], 7-9 = individual employee [pegawai perorangan]).

C<sss.sss> is a 6-digit serial code for the taxpayer, probably starts
from 1. It is distributed in blocks by the central tax office (kantor
pusat dirjen pajak, DJP) to the local tax offices (kantor pelayanan
pajak, KPP) throughout the country for allocation to taypayers.

C<C> is a check digit. Due to lack of documentation, the checking of
check digits is not yet implemented by this module.

C<OOO> is a 3-digit local tax office code (kode KPP).

C<BBB> is a 3-digit branch code. C<000> means the taxpayer is the sole
branch (or, for individuals, the head of the family). C<001>, C<002>,
and so on denote each branch.

=cut

=head1 METHODS

=head2 new $str

Create a new C<Business::ID::NPWP> object.

=cut

sub new {
    my ($class, $str) = @_;
    bless {
	_str => $str,
	_err => undef, # errstr
	_res => undef, # validation result cache
    }, $class;
}

=head2 validate()

Return true if NPWP is valid, or false if otherwise. In the case of NPWP
being invalid, you can call the errstr() method to get a description
of the error.

=cut

sub validate {
    my ($self, $another) = @_;
    return validate_npwp($another) if $another;
    return $self->{_res} if defined($self->{_res});

    $self->{_res} = 0;
    for ($self->{_str}) {
	s/^\s+//;
	# assume A = 0 if not specified
	if (/^\d\./) { $_ = "0$_" }
	s/\D+//g;
	# assume BBB = 000 if not specified
	if (length == 12) { $_ .= "000" }
	if (length != 15) {
	    $self->{_err} = "not 15 digit";
	    return;
	}
	/^..(\d{6})/;
	if ($1 < 1) {
	    $self->{_err} = "serial starts from 1, not 0";
	    return;
	}
    }
    $self->{_res} = 1;
}

=head2 errstr()

Return validation error of NPWP, or undef if no error is found. See
C<validate()>.

=cut

sub errstr {
    my ($self) = @_;
    $self->validate and return;
    $self->{_err};
}

=head2 normalize()

Return formatted NPWP, or undef if NPWP is invalid.

=cut

sub normalize {
    my ($self, $another) = @_;
    return Business::ID::NPWP->new($another)->normalize if $another;
    $self->validate or return;
    $self->{_str} =~ /^(..)(...)(...)(.)(...)(...)/;
    "$1.$2.$3.$4-$5.$6";
}

=head2 pretty()

Alias for normalize().

=cut

sub pretty { normalize(@_) }

=head2 taxpayer_code()

Return 2-digit taxpayer code component of NPWP, or undef if NPWP is invalid.

=cut

sub taxpayer_code {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /^(..)/;
    $1;
}

=head2 kode_wajib_pajak()

Alias for taxpayer_code().

=cut

sub kode_wajib_pajak { taxpayer_code(@_) }

=head2 kode_wp()

Alias for taxpayer_code().

=cut

sub kode_wp { taxpayer_code(@_) }

=head2 serial()

Return 6-digit serial component of NPWP, or undef if NPWP is invalid.

=cut

sub serial {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /^\d{2}(......)/;
    $1;
}

=head2 check_digit()

Return check digit component of NPWP, or undef if NPWP is invalid.

=cut

sub check_digit {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /^\d{8}(.)/;
    $1;
}

=head2 local_tax_office_code()

Return 3-digit local tax office code component of NPWP, or undef if NPWP is invalid.

=cut

sub local_tax_office_code {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /^\d{9}(...)/;
    $1;
}

=head2 kode_kpp()

Alias for local_tax_office_code().

=cut

sub kode_kpp { local_tax_office_code(@_) }

=head2 branch_code()

Return 3-digit branch code component of NPWP, or undef if NPWP is invalid.

=cut

sub branch_code {
    my ($self) = @_;
    $self->validate or return;
    $self->{_str} =~ /^\d{12}(...)/;
    $1;
}

=head2 kode_cabang()

Alias for branch_code().

=cut

sub kode_cabang { branch_code(@_) }

=head1 FUNCTIONS

=head2 validate_npwp($string)

Return true if NPWP is valid, or false if otherwise. If you want to
know the error details, you need to use the OO version (see the
C<errstr> method).

Exported by default.

=cut

sub validate_npwp {
    my ($str) = @_;
    Business::ID::NPWP->new($str)->validate();
}

=head1 AUTHOR

Steven Haryanto, C<< <stevenharyanto at gmail.com> >>

=head1 BUGS

The list of valid 'province' codes in the program might need to be
updated from time to time.

Please report any bugs or feature requests to C<bug-business-id-npwp at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Business-ID-NPWP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Business::ID::NPWP


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-ID-NPWP>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Business-ID-NPWP>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Business-ID-NPWP>

=item * Search CPAN

L<http://search.cpan.org/dist/Business-ID-NPWP/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Steven Haryanto.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
