package CatalystX::Test::Recorder::Controller;

use strict;
use warnings;
use utf8;
use Template::Alloy;
use Perl::Tidy;
use Data::Dumper;

use base 'Catalyst::Controller';

__PACKAGE__->config( namespace => 'recorder' );

our $requests = [];
our $responses = [];
our $record   = 0;

my $template = do { local $/ = undef; <DATA> };

sub start : Local {
    my ( $self, $c ) = @_;
    $requests = []; $responses = [];
    $record   = 1;
    $c->res->body('Recording...');
}

sub stop : Local {
    my ( $self, $c ) = @_;
    if ($record) {
        shift(@$requests);
        shift(@$responses);
    }
    $record = 0;
    my $test = '';
    my $tt   = Template::Alloy->new(
        DUMP    => { html => 0, header => 0 },
        FILTERS => {
            perltidy => sub {
                my $formated;
                Perl::Tidy::perltidy(
                    source      => \$_[0],
                    destination => \$formated,
                );

                return $formated;
              }
        }
    );
    $tt->define_vmethod(
        'hash', dump => sub {
            my $dump = Dumper $_[0];
            $dump =~ s/^.*?{(.*)}.*?$/$1/s;
            $dump =~ s/\n//g;
            return $dump;
        });
    $tt->process( \$template, { requests => $requests, responses => $responses, app => ref $c }, \$test )
      or die $!;
    $c->res->body($test);

}

sub end : Private {
    my ( $self, $c ) = @_;
    $c->res->content_type('text/plain');
}

1;

__DATA__
[% FILTER perltidy -%]
# [% requests.size %] requests recorded.

use Test::More;
use strict;
use warnings;

use URI;
use HTTP::Request::Common qw(GET HEAD PUT DELETE POST);

use Test::WWW::Mechanize::Catalyst '[% app %]';

my $mech = Test::WWW::Mechanize::Catalyst->new();

my ($response, $request, $url);

[% FOREACH request IN requests %]
[% IF request.query_params.size %]$url = URI->new('/[% request.path %]');
$url->query_form( { [% request.query_params.dump %] } );
[% END -%]
$request = [% IF request.body_params.size; 'POST'; ELSE; request.method; END -%] 
[% IF request.query_params.size; '$url'; ELSE; "'/" _ request.path _ "'"; END -%]
[% IF request.body_params.size; ', [' _ request.body_params.dump _ ']'; END %];
[% IF request.body_params.size && request.method != 'POST'; '$request->method(\'' _ request.method _ '\');'; END -%]
$response = $mech->request($request);
is($response->code, [% responses.${loop.index}.code %]);
[% END %]

done_testing;
[%- END -%]
