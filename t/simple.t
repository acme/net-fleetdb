#!perl
use strict;
use warnings;
use Net::FleetDB;
use Test::More tests => 16;

my $fleetdb = Net::FleetDB->new(
    host => '127.0.0.1',
    port => 3400,
);

is( $fleetdb->call('ping'), 'pong', '["ping"]' );

ok( $fleetdb->call( 'delete', 'people' ), '["delete","people"]' );
ok( $fleetdb->call( 'drop-index', 'people', 'name' ),
    '["drop-index","people","name"]' );
is( $fleetdb->call( 'count', 'people' ), 0, '["count","people"]' );

is( $fleetdb->call( 'insert', 'people', { 'id' => 1, 'name' => 'Bob' } ),
    1, '["insert","people",{"name":"Bob","id":1}]' );
is( $fleetdb->call( 'count', 'people' ), 1, '["count","people"]' );

is( $fleetdb->call( 'update', 'people', { 'id' => 1, 'name' => 'Bobby' } ),
    1, '["update","people",{"name":"Bobby","id":1}]' );
is( $fleetdb->call( 'count', 'people' ), 1, '["count","people"]' );

is( $fleetdb->call(
        'insert', 'people',
        [ { 'id' => 2, 'name' => 'Bob2' }, { 'id' => 3, 'name' => 'Amy' } ]
    ),
    2,
    '["insert","people",[{"name":"Bob2","id":2},{"name":"Amy","id":3}]]'
);
is( $fleetdb->call( 'count', 'people' ), 3, '["count","people"]' );
is( $fleetdb->call( 'count', 'people', { 'where' => [ '>', 'id', 2 ] } ),
    1, '["count","people",{"where":[">","id",2]}]' );

is( $fleetdb->call( 'create-index', 'people', 'name' ),
    1, '["create-index","people","name"]' );

is_deeply(
    $fleetdb->call( 'select', 'people', { 'order' => [ 'id', 'asc' ] } ),
    [   { 'id' => 1, 'name' => 'Bobby' },
        { 'id' => 2, 'name' => 'Bob2' },
        { 'id' => 3, 'name' => 'Amy' },
    ],
    '["select","people",{"order":["id","asc"]}]'
);

is_deeply(
    $fleetdb->call( 'select', 'people', { 'order' => [ 'name', 'asc' ] } ),
    [   { 'id' => 3, 'name' => 'Amy' },
        { 'id' => 2, 'name' => 'Bob2' },
        { 'id' => 1, 'name' => 'Bobby' },
    ],
    '["select","people",{"order":["name","asc"]}]'
);

is( $fleetdb->call(
        'delete', 'people', { 'where' => [ '=', 'name', 'Bobby' ] }
    ),
    1,
    '["delete","people",{"where":["=","name","Bobby"]}]'
);
is( $fleetdb->call( 'count', 'people' ), 2, '["count","people"]' );

foreach my $collection ( @{ $fleetdb->call('list-collections') } ) {
    warn $collection;
}
