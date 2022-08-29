package Net::MBE::Item {
    use Moo;
    use namespace::clean;
    use SOAP::Lite;
    use Arthas::Defaults::520;

    # Mandatory fields
	has weight => ( is => 'rw' );
	has length => ( is => 'rw' );
	has width => ( is => 'rw' );
	has height => ( is => 'rw' );

	sub BUILD($class, $args) {
        croak 'Provide-weight' if !$args->{weight};
        croak 'Provide-length' if !$args->{length};
        croak 'Provide-width' if !$args->{width};
        croak 'Provide-height' if !$args->{height};
	}

    sub getSoapParams($self) {
        return \SOAP::Data->value(
            SOAP::Data->name('Weight', $self->weight),
            SOAP::Data->name('Dimensions' =>  \SOAP::Data->value(
                SOAP::Data->name('Length', $self->length),
                SOAP::Data->name('Height', $self->height),
                SOAP::Data->name('Width', $self->width),
            )),
        );
    }
}

1;

=head1 NAME

Net::MBE::Item - Object representing an item to ship (i.e. a package).

=head1 DESCRIPTIOM

To be used with C<Shipment> and C<ShippingOptions> methods of L<Net::MBE>.

This class is not meant to be created directly but through the C<addItem> functions of L<Net::MBE::ShippingParameters>.

=head1 AUTHOR

Michele Beltrame, C<arthas@cpan.org>

=head1 LICENSE

This library is free software under the Mozilla Public License 2.0.
