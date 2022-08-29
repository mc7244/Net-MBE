package Net::MBE::ShippingOptionsResponse {
	use Moo;
    use namespace::clean;
    use Net::MBE::ShippingOption;
    use Arthas::Defaults::520;

    has 'shippingOptions' => ( is => 'ro' );

	sub BUILD($class, $args) {
        croak 'Provide-shippingOptions' if !$args->{shippingOptions};
	}
}

1;

=head1 NAME

Net::MBE::ShippingOptionsResponse - Response object for C<ShippingOptions>.

=head1 PROPERTIES

=over

=item shippingOptions

An array for L<Net::MBE::ShippingOption> objects. I<Read-only>.

=back

=head1 AUTHOR

Michele Beltrame, C<arthas@cpan.org>

=head1 LICENSE

This library is free software under the Mozilla Public License 2.0.

