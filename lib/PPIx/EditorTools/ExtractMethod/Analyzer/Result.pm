package PPIx::EditorTools::ExtractMethod::Analyzer::Result;
use Moose;

has 'variables'   => ( is => 'ro', isa => 'HashRef', default => sub { {} });
has 'return_statement_at_end'   => ( is => 'ro', isa => 'Bool', default => 0 );

1;

__END__

=pod

=head1 AUTHORS

Dagfinn Reiersøl L<https://github.com/dagfinnr>

=head2 CONTRIBUTORS

MGRIMES

Gabor Szabo E<lt>gabor@szabgab.comE<gt>

=head1 SEE ALSO

L<PPIx::EditorTools>, L<App::EditorTools>, L<Padre>, and L<PPI>.

=cut
