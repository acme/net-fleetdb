package Net::FleetDB;
use warnings;
use strict;
use Carp qw(cluck);
use IO::Socket::INET;
use JSON::XS::VersionOneAndTwo;

sub new {
    my ( $class, %args ) = @_;

    my $host = delete $args{host} || '127.0.0.1';
    my $port = delete $args{port} || 3400;

    my $socket = IO::Socket::INET->new(
        PeerHost => $host,
        PeerPort => $port,
        Timeout  => 60
    );

    my $self = bless {
        host   => $host,
        port   => $port,
        socket => $socket,
    }, $class;
    return $self;
}

sub call {
    my ( $self, @args ) = @_;
    my $socket  = $self->{socket};
    my $request = to_json( \@args );
    warn "-> $request\n" if 1;
    $socket->print( $request . "\n" ) || die $!;
    my $response = $socket->getline;
    warn "<- $response" if 0;
    my $return = from_json($response);

    if ( $return->[0] != 0 ) {
        cluck( $return->[1] );
    } else {
        return $return->[1];
    }
}

1;
