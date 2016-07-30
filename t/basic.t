use strict;
use warnings;
use Test::More;
use Test::Exception;

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

  package Yet::Another::Class;
  use Mouse;
  with 'MouseX::Traits';
  has '+_trait_namespace' => ( default => sub {
      require Mouse::Util;
      join '::', Mouse::Util::find_meta(shift)->name, 'Traits';
  });

  package Yet::Another::Class::Traits::Faves;
  use Mouse::Util::TypeConstraints;
  use Mouse::Role;
  has 'favorite_thing' => (
    is       => 'ro',
    isa      => enum(qw(
      RaindropsOnRoses
      WhiskersOnKittens
      BrightCopperKettles
    )),
    required => 1
  );

}

foreach my $trait ( 'Trait', ['Trait' ] ) {
    my $instance = Class->new_with_traits( traits => $trait, foo => 'hello' );
    isa_ok $instance, 'Class';
    can_ok $instance, 'foo';
    is $instance->foo, 'hello';
}

throws_ok {
    Class->with_traits('Trait')->new;
} qr/required/, 'foo is required';

{
    my $instance = Class->with_traits->new;
    isa_ok $instance, 'Class';
    ok !$instance->can('foo'), 'this one cannot foo';
}
{
    my $instance = Class->with_traits()->new;
    isa_ok $instance, 'Class';
    ok !$instance->can('foo'), 'this one cannot foo either';
}
{
    my $instance = Another::Class->with_traits( 'Trait' )->new( bar => 'bar' );
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'bar';
    is $instance->bar, 'bar';
}
# try hashref form
{
    my $instance = Another::Class->with_traits('Trait')->new({ bar => 'bar' });
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'bar';
    is $instance->bar, 'bar';
}
{
    my $instance = Another::Class->with_traits('Trait', '+Trait')->new(
        foo => 'foo',
        bar => 'bar',
    );
    isa_ok $instance, 'Another::Class';
    can_ok $instance, 'foo';
    can_ok $instance, 'bar';
    is $instance->foo, 'foo';
    is $instance->bar, 'bar';
}
{
    my $instance = Yet::Another::Class->with_traits('Faves')->new(
        favorite_thing => 'WhiskersOnKittens',
    );
    isa_ok $instance, 'Yet::Another::Class';
    can_ok $instance, 'favorite_thing';
    is $instance->favorite_thing, 'WhiskersOnKittens';
    ok $instance->does('Yet::Another::Class::Traits::Faves');
}

done_testing;
