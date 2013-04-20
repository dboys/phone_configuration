use utf8;
package DB::Schema::Result::HtmlInfo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

DB::Schema::Result::HtmlInfo

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<html_info>

=cut

__PACKAGE__->table("html_info");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 proxy_id

  data_type: 'text'
  is_nullable: 0

=head2 login_id

  data_type: 'text'
  is_nullable: 0

=head2 passwd_id

  data_type: 'text'
  is_nullable: 0

=head2 ip

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "proxy_id",
  { data_type => "text", is_nullable => 0 },
  "login_id",
  { data_type => "text", is_nullable => 0 },
  "passwd_id",
  { data_type => "text", is_nullable => 0 },
  "ip",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-04-19 14:32:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:66pThxSZx0aG7h/IfNxHAQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
