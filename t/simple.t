#!perl
use strict;
use warnings;
use Net::FleetDB;
use Test::Exception;
use Test::More;

my $fleetdb;
eval { $fleetdb = Net::FleetDB->new( host => '127.0.0.1', port => 3400 ); };

plan skip_all => "Local FleetDB needed for testing: $@" if $@;
plan tests => 17;

is( $fleetdb->query('ping'), 'pong', '["ping"]' );

throws_ok( sub { $fleetdb->query('NOTAMETHOD') },
    qr/Malformed query: unrecognized query type '"NOTAMETHOD"'/ );

ok( $fleetdb->query( 'delete', 'people' ), '["delete","people"]' );
ok( $fleetdb->query( 'drop-index', 'people', 'name' ),
    '["drop-index","people","name"]' );
is( $fleetdb->query( 'count', 'people' ), 0, '["count","people"]' );

is( $fleetdb->query( 'insert', 'people', { 'id' => 1, 'name' => 'Bob' } ),
    1, '["insert","people",{"name":"Bob","id":1}]' );
is( $fleetdb->query( 'count', 'people' ), 1, '["count","people"]' );

is( $fleetdb->query( 'update', 'people', { 'id' => 1, 'name' => 'Bobby' } ),
    1, '["update","people",{"name":"Bobby","id":1}]' );
is( $fleetdb->query( 'count', 'people' ), 1, '["count","people"]' );

is( $fleetdb->query(
        'insert', 'people',
        [ { 'id' => 2, 'name' => 'Bob2' }, { 'id' => 3, 'name' => 'Amy' } ]
    ),
    2,
    '["insert","people",[{"name":"Bob2","id":2},{"name":"Amy","id":3}]]'
);
is( $fleetdb->query( 'count', 'people' ), 3, '["count","people"]' );
is( $fleetdb->query( 'count', 'people', { 'where' => [ '>', 'id', 2 ] } ),
    1, '["count","people",{"where":[">","id",2]}]' );

is( $fleetdb->query( 'create-index', 'people', 'name' ),
    1, '["create-index","people","name"]' );

is_deeply(
    $fleetdb->query( 'select', 'people', { 'order' => [ 'id', 'asc' ] } ),
    [   { 'id' => 1, 'name' => 'Bobby' },
        { 'id' => 2, 'name' => 'Bob2' },
        { 'id' => 3, 'name' => 'Amy' },
    ],
    '["select","people",{"order":["id","asc"]}]'
);

is_deeply(
    $fleetdb->query( 'select', 'people', { 'order' => [ 'name', 'asc' ] } ),
    [   { 'id' => 3, 'name' => 'Amy' },
        { 'id' => 2, 'name' => 'Bob2' },
        { 'id' => 1, 'name' => 'Bobby' },
    ],
    '["select","people",{"order":["name","asc"]}]'
);

is( $fleetdb->query(
        'delete', 'people', { 'where' => [ '=', 'name', 'Bobby' ] }
    ),
    1,
    '["delete","people",{"where":["=","name","Bobby"]}]'
);
is( $fleetdb->query( 'count', 'people' ), 2, '["count","people"]' );

foreach my $collection ( @{ $fleetdb->query('list-collections') } ) {
    warn $collection;
}
