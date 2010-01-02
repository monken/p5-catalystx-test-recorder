package CatalystX::Test::Recorder;

use strict;
use warnings;
use Moose::Role;

around locate_components => sub {
    my $orig = shift;
    my $self = shift;
    my @components = $self->$orig(@_);
    push(@components, 'CatalystX::Test::Recorder::Controller');
    return @components;
};

after finalize => sub {
    my $c = shift;
    return unless $CatalystX::Test::Recorder::Controller::record;
    push(@{$CatalystX::Test::Recorder::Controller::requests}, $c->req);
    push(@{$CatalystX::Test::Recorder::Controller::responses}, $c->res);
    
};

# use MooseX::RelatedClassRoles;
# use CatalystX::Test::Recorder::RequestTrait;

# BEGIN { extends 'Catalyst::Controller'; };
# 
# sub start : Local {
#     my ($self, $c) = @_;
#     unless( $c->request_class->isa('CatalystX::Test::Recorder::RequestTrait') ) {
#         $c->request_class(Moose::Meta::Class->create_anon_class(
#               superclasses => [ $c->request_class ],
#               roles        => [ qw(CatalystX::Test::Recorder::RequestTrait) ],
#               cache        => 1,
#             )->name);
#     }
#     die unless $c->request_class->isa('CatalystX::Test::Recorder::RequestTrait');
#     $c->request_class->
#     $c->res->body('Started recording...');
# }

1;