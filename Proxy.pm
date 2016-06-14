#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

=head1 NAME

TestCluster::Proxy - Proxy Modul for Rex::Test::Base

=head1 DESCRIPTION

Proxy requests to Rex::Test::Base and set connection.

=head1 EXAMPLE


=cut

package TestCluster::Proxy;

use strict;
use warnings;

# VERSION

use Moose;

require Rex::Test::Base;

has test => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my ($self) = @_;
    return Rex::Test::Base->new( box => $self->box );
  },
);

has box => ( is => 'ro', );

has connection => (
  is     => 'ro',
  writer => '_set_connection',
);

sub exec {
  my ( $self, $code ) = @_;

  $self->_connect;

  $code->();

  Rex::pop_connection();

  return;
}

sub to_server_object {
  my ($self) = @_;
  return Rex::Group::Entry::Server->new(
    name => $self->box->ip,
    auth => $self->box->auth,
  );
}

sub _connect {
  my ($self) = @_;

  if ( $self->connection ) {
    Rex::connect( cached_connection => $self->connection );
  }
  else {
    $self->_set_connection(
      Rex::connect(
        server => $self->box->ip,
        %{ $self->box->auth },
      )
    );
  }
}

our $AUTOLOAD;

sub AUTOLOAD {
  my $self = shift or return;
  ( my $method = $AUTOLOAD ) =~ s{.*::}{};

  $self->_connect;

  $self->test->$method(@_);

  Rex::pop_connection();
}

1;
