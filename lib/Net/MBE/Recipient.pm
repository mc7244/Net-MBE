=head1 NAME

Net::MBE::Recepient

=head1 DESCRIPTION

See L<Net::MBE> for documentation.

=head1 AUTHOR

Michele Beltrame, C<arthas@cpan.org>

=head1 LICENSE

This library is free software under the Mozilla Public License 2.0.

=cut

# Recipient
# --------
# To be used with Shipment request.
# Mandatory fields:
#	name, companyname, address, phone, zipcode, city, country, email
package Net::MBE::Recipient {
    use Moo;
    use namespace::clean;
    use SOAP::Lite;
    use Arthas::Defaults::520;

    # Mandatory fields
	has name => ( is => 'rw' );
	has companyName => ( is => 'rw' );
	has address => ( is => 'rw' );
	has phone => ( is => 'rw' );
	has zipCode => ( is => 'rw' );
	has city => ( is => 'rw' );
	has country => ( is => 'rw' );
	has email => ( is => 'rw' );

	# Optional fields
	has state => ( is => 'rw' );
	has subzoneID => ( is => 'rw', default => sub { 0 } );
	has subzoneDesc => ( is => 'rw' );

	sub BUILD($class, $args) {
        croak 'Provide-name' if !$args->{name};
        croak 'Provide-companyName' if !$args->{companyName};
        croak 'Provide-address' if !$args->{address};
        croak 'Provide-phone' if !$args->{phone};
        croak 'Provide-zipCode' if !$args->{zipCode};
        croak 'Provide-city' if !$args->{city};
        croak 'Provide-country' if !$args->{country};
        croak 'Provide-email' if !$args->{email};
	}

    sub getSoapParams($self) {
        my @fields = (
            SOAP::Data->name('name' => $self->name),
            SOAP::Data->name('companyName' => $self->companyName),
            SOAP::Data->name('address' => $self->address),
            SOAP::Data->name('phone' => $self->phone),
            SOAP::Data->name('zipCode' => $self->zipCode),
            SOAP::Data->name('city' => $self->city),
            SOAP::Data->name('country' => $self->country),
            SOAP::Data->name('email' => $self->email),
        );
        if ( $self->state ) { push @fields, SOAP::Data->name('State' => $self->state); }
        if ( $self->subzoneID ) { push @fields, SOAP::Data->name('subzoneID' => $self->subzoneID); }
        if ( $self->subzoneDesc ) { push @fields, SOAP::Data->name('subzoneDesc' => $self->dscdSubzone); }
        return \SOAP::Data->value(@fields);
    }
}

1;