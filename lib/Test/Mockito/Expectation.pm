package Test::Mockito::Expectation;
use Moose;

with 'Test::Mockito::Role::MethodCall';

sub satisfied_by {
    my ($self, $invocation) = @_;
    return
        $invocation->method_name eq $self->method_name &&
        $invocation->arguments ~~ $self->arguments
}

1;
