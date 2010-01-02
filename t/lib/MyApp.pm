package MyApp;
use Moose;
extends 'Catalyst';
with 'CatalystX::Test::Recorder';
__PACKAGE__->setup;
1;