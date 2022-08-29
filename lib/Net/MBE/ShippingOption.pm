package Net::MBE::ShippingOption {
	use Moo;
    use namespace::clean;
    use Arthas::Defaults::520;

    has 'CODAvailable'          => ( is => 'ro' );
    has 'Courier'               => ( is => 'ro' );
    has 'CourierDesc'           => ( is => 'ro' );
    has 'CourierService'        => ( is => 'ro' );
    has 'CourierServiceDesc'    => ( is => 'ro' );
    has 'CustomDuties'          => ( is => 'ro' );
    has 'IdSubzone'             => ( is => 'ro' );
    has 'InsuranceAvailable'    => ( is => 'ro' );
    has 'MBESafeValueAvailable' => ( is => 'ro' );
    has 'NetShipmentPrice'      => ( is => 'ro' );
    has 'NetShipmentTotalPrice' => ( is => 'ro' );
    has 'Service'               => ( is => 'ro' );
    has 'ServiceDesc'           => ( is => 'ro' );
    has 'SubzoneDesc'           => ( is => 'ro' );
}

1;

=head1 NAME

Net::MBE::ShippingOptionsResponse - Response object for C<ShippingOptions>.

=head1 PROPERTIES

All options are I<read-only>.

=over

=item CODAvailable

I<true> or I<false>.

=item Courier

I.e. I<SDA>.

=item CourierDesc

I.e. I<SDA>.

=item CourierService

I.e. I<SEX>.

=item CustomDuties

I<true> or I<false>.

=item IdSubzone

I.e. I<44>.

=item InsuranceAvailable

I<true> or I<false>.

=item MBESafeValueAvailable

I<true> or I<false>.

=item NetShipmentPrice

I.e. I<5.89>.

=item NetShipmentTotalPrice

I.e. I<MBE>.

=item Service

I.e. I<7.08>.

=item ServiceDesc

I.e. I<MBE Standard>.

=item SubzoneDesc

I.e. I<Pordenone>.

=back

=head1 AUTHOR

Michele Beltrame, C<arthas@cpan.org>

=head1 LICENSE

This library is free software under the Mozilla Public License 2.0.

