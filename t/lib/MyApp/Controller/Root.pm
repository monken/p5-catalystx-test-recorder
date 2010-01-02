package MyApp::Controller::Root;
use strict;
use warnings;
use base 'Catalyst::Controller';    
__PACKAGE__->config(namespace => '');
sub foo : Local {}

sub code304 : Local {
    my ($self, $c) = @_;
    $c->response->code(304);
}

sub cookie : Local {
    my ($self, $c) = @_;
    if($c->req->cookie('cookietest')) {
        $c->res->code(404);
    } else {
        $c->res->cookies->{cookietest} = { value => 1 }; 
    }
}

1;