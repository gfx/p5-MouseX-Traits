use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;

use MouseX::Traits; # for "no warnings ..."

{ package Trait;
  use Mouse::Role;
  has 'foo' => (
      is       => 'ro',
      isa      => 'Str',
      required => 1,
  );

  package Class;
  use Mouse;
  with 'MouseX::Traits';

  package Another::Trait;
  use Mouse::Role;
  has 'bar' => (
      is       => 'ro',
      isa      => 'Str',
      required => 1,
  );

  package Another::Class;
  use Mouse;
  with 'MouseX::Traits';
  has '+_trait_namespace' => ( default => 'Another' );

}

use MouseX::Traits::Util qw(new_class_with_traits);

dies_ok {
    new_class_with_traits( 'OH NOES', 'Foo' );
} ' NOES is not a MX::Traits class';

dies_ok {
    new_class_with_traits( 'Mouse::Meta::Class', 'Foo' );
} 'Mouse::Meta::Class is not a MX::Traits class';

my $class;
lives_ok {
    $class = new_class_with_traits( 'Class' => 'Trait', 'Another::Trait' );
} 'new_class_with_traits works';

ok $class;

my $instance = $class->name->new( foo => '42', bar => '24' );
is $instance->foo, 42;
is $instance->bar, 24;
