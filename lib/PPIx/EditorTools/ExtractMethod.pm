package PPIx::EditorTools::ExtractMethod;

# ABSTRACT: Extract a block of code into a method

use Moose;

our $VERSION = '0.01';

use PPI::Document;
use PPIx::EditorTools;
use PPIx::EditorTools::ExtractMethod::LineRange;
use aliased 'PPIx::EditorTools::ExtractMethod::Analyzer';
use aliased 'PPIx::EditorTools::ExtractMethod::VariableSorter';
use aliased 'PPIx::EditorTools::ExtractMethod::CodeGenerator';
use aliased 'PPIx::EditorTools::ExtractMethod::CodeEditor';

=pod

=head1 NAME

PPIx::EditorTools::ExtractMethod - Extract a block of code into a method

=head1 SYNOPSIS

    my $extractor = PPIx::EditorTools::ExtractMethod->new(
        code           => $code,
        selected_range => [122,150],
    );

    $extractor->extract_method('symbol_patterns');
    my $new_code = $extractor->code;

=head1 DESCRIPTION

Tool to extract a block of code into its own method. Taking great care to
pass in variables and return variables as needed.  According to dagfinnr, this
is a "serious attempt to get serious refactoring tool support for Perl code."
See his L<https://github.com/dagfinnr/perl-extract-method> for discussion
of the method.

=cut

has 'code'   => ( is => 'rw', isa => 'Str' );

has 'selected_range' => (
    is => 'rw',
    isa => 'PPIx::EditorTools::ExtractMethod::LineRange',
    coerce => 1,
);

has 'analyzer'   => ( 
    is => 'ro', 
    isa => 'PPIx::EditorTools::ExtractMethod::Analyzer',
    builder => '_build_analyzer',
    lazy => 1,
);
has 'sorter'   => ( 
    is => 'ro', 
    isa => 'PPIx::EditorTools::ExtractMethod::VariableSorter',
    builder => '_build_sorter',
    lazy => 1,
);
has 'generator'   => ( 
    is => 'ro', 
    isa => 'PPIx::EditorTools::ExtractMethod::CodeGenerator',
    builder => '_build_generator',
    lazy => 1,
    required => 1,
);

sub _build_generator {
    my $self = shift;
    return CodeGenerator->new(
        sorter => $self->sorter,
        selected_range => $self->selected_range,
        selected_code => $self->analyzer->selected_code,
    );
}

sub _build_sorter {
    my $self = shift;
    return VariableSorter->new;
}
sub _build_analyzer {
    my $self = shift;
    my $analyzer = Analyzer->new();
    $analyzer->code($self->code);
    $analyzer->selected_range($self->selected_range);
    return $analyzer;
}

=head2 extract_method

Main method for the Extract Method refactoring. Analyzes variables in the selected
code, finds out which of them need to be passed or returned from the extracted method,
generates the new method and the call to it, and edits the document to insert the
generated code at the appropriate places.

=cut

sub extract_method {
    my ($self, $name) = @_;
    $self->sorter->input($self->analyzer->result->variables);
    $self->sorter->analyzer_result($self->analyzer->result);
    $self->sorter->process_input;
    my $editor = CodeEditor->new(
        code => $self->code,
        replacement => $self->generator->method_call($name)
    );
    $editor->selected_range($self->selected_range);
    $editor->replace_selected_lines();
    $editor->insert_after(
        $editor->end_of_sub,
        $self->generator->method_body($name)
    );
    $self->code($editor->code);
}
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
