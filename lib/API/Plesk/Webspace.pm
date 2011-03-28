
package API::Plesk::Webspace;

use strict;
use warnings;

use Carp;
use Data::Dumper;

use base 'API::Plesk::Component';

my @gen_setup_fields = qw(
    name
    owner-id
    owner-login
    owner-guid
    owner-external-id
    htype
    ip_address
    status
    external-id
);


sub add {
    my ( $self, %params ) = @_;
    my $bulk_send = delete $params{bulk_send};
    my $gen_setup = $params{gen_setup} || confess "Required gen_setup parameter!";

    $self->check_hosting(\%params);

    $self->check_required_params(\%params, [qw(plan-id plan-name plan-guid plan-external-id)]);
    $self->check_required_params($gen_setup, qw(name ip_address));

    $params{gen_setup} = $self->sort_params($gen_setup, @gen_setup_fields);

    return $bulk_send ? \%params :
        $self->plesk->send('webspace', 'add', \%params);
}

sub get {
    my ($self, %filter) = @_;
    my $bulk_send = delete $filter{bulk_send};
    my $dataset   = {gen_info => ''};
    
    if ( my $add = delete $filter{dataset} ) {
        $dataset = { map { ( $_ => '' ) } ref $add ? @$add : ($add) };
        $dataset->{gen_info} = '';
    }

    my $data = { 
        filter  => @_ > 2 ? \%filter : '',
        dataset => $dataset,
    };

    return $bulk_send ? $data : 
        $self->plesk->send('webspace', 'get', $data);
}

sub set {
    my ( $self, %params ) = @_;
    my $bulk_send = delete $params{bulk_send}; 
    my $filter    = delete $params{filter} || '';
    
    $self->check_hosting(\%params);

    my $data = {
        filter  => $filter,
        values  => \%params,
    };

    return $bulk_send ? $data : 
        $self->plesk->send('webspace', 'set', $data);
}

sub del {
    my ($self, %filter) = @_;
    my $bulk_send = delete $filter{bulk_send}; 

    my $data = {
        filter  => @_ > 2 ? \%filter : ''
    };

    return $bulk_send ? $data : 
        $self->plesk->send('webspace', 'del', $data);
}

sub add_plan_item {
    my ( $self, %params ) = @_;
    my $bulk_send = delete $params{bulk_send}; 
    my $filter    = delete $params{filter} || '';

    my $name = $params{name} || confess "Required name field!";    
    my $data = {
        filter      => $filter,
        'plan-item' => { name => $name },
    };

    return $bulk_send ? $data : 
        $self->plesk->send('webspace', 'add-plan-item', $data);
}


1;