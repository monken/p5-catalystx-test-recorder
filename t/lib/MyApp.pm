package MyApp;
use Moose;
extends 'Catalyst';
__PACKAGE__->config( 'CatalystX::Test::Recorder' => { skip => [qr/^static/], namespace => 'recorder' } );
__PACKAGE__->setup(qw(+CatalystX::Test::Recorder));
1;