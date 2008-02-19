
package Class::Lego::Constructor;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.003';

use Exporter::Lite;
BEGIN {
  our @EXPORT = qw( defer lazy );
}

use Scalar::Defer 0.13 qw( defer lazy );
# &defer and &lazy are imported just to be exported

sub mk_constructor0 {
  my $self = shift;
  my $params = shift;

  my $class = ref $self || $self;
  my $sub = $self->make_constructor0($params);
  my $subname = $class . '::new';

  no strict 'refs';
  *{$subname} = $sub;
}

#sub _is_deferred {
#  UNIVERSAL::isa( shift, 'Scalar::Defer::Deferred' );
#}


# from Class::Accessor
sub new {
  my($proto, $fields) = @_;
  my($class) = ref $proto || $proto;

  $fields = {} unless defined $fields;

  # make a copy of $fields.
  bless {%$fields}, $class;
}

use SUPER;

sub make_constructor0 {
  my $self = shift;
  my $params = shift || {};

  # return a closure
  return sub {
    my $self = shift;
    my $fields = shift;
    my %f = %{ $fields || {} };
    while ( my ($k, $v) = each %$params ) {
      if ( !exists $f{$k} ) {
        $f{$k} = Scalar::Defer::is_deferred($v) ? Scalar::Defer::force($v) : $v;
      }
    }
    return $self->super('new')->( $self, \%f );

  };
}

1;
