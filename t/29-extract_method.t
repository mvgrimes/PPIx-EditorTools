use Test::More;
use Test::Differences;
use PPIx::EditorTools::ExtractMethod;
use FindBin;
use Path::Tiny;

my $extractor;

subtest 'integration test' => sub  {
    ok(1);
    my $code = path($FindBin::Bin . '/data/input/RenameVariable.pm')->slurp_utf8;
    my $expected = path($FindBin::Bin . '/data/output/RenameVariable.pm')->slurp_utf8;
    my $extractor = PPIx::EditorTools::ExtractMethod->new(
        code => $code,
        selected_range => [122,150],
    );

    $extractor->extract_method('symbol_patterns');
    ## path('/tmp/RenameVariable.pm', $extractor->code)->spew_utf8;
    eq_or_diff($extractor->code . "\n", $expected);
};

subtest 'extract method from extract method' => sub  {
    my $code = path($FindBin::Bin . '/data/input/extract_method.pl')->slurp_utf8;
    my $extractor = PPIx::EditorTools::ExtractMethod->new(
        code => $code,
        selected_range => [6,10],
    );
    $extractor->extract_method('foo');
    like($extractor->code,
        qr/my \(\$editor\).*\$editor = \$self->foo\(\$name\);/s
    );
};

done_testing();

