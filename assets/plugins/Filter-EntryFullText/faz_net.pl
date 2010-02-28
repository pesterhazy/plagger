use HTML::Scrubber;
use LWP::Simple;
use HTML::TreeBuilder::XPath;
use File::Slurp;

sub handle {
    my($self, $args) = @_;

#    print $args->{entry}->permalink . "\n"; # for debugging

    $args->{entry}->permalink =~ m!http://.*\.faz\.net!;
#    $args->{entry}->permalink eq 'http://www.faz.net/s/RubDA5AEED6E6AB48F9A65EA41107C817DD/Doc~E860009E060A34688A7E7B774EA57AAB1~ATpl~Ecommon~Sspezial.html?rss_feuilleton';
}

sub extract {
  my($self, $args) = @_;
  my $str = $args->{content};
  my $body;

  my $tree= HTML::TreeBuilder::XPath->new;
  $tree->parse($str);

  my $nodes;
  $nodes=$tree->findnodes('//div[@class="BlogPost"]');
  if ( !$nodes ) {
    $nodes=$tree->findnodes('//div[@class="Article"]');
    if ( !$nodes ) {
      $nodes=$tree->findnodes('//div[@id="MedContent"]');
      if ( !$nodes ) {
        print("WARNING: No such div found\n");
        return;
      }
    }
  }
  my $anke = $nodes->get_node(1);

  my @to_delete = (
    './div[@id="ArtikelServicesMenu"]',
    './div[@class="BoxTool Aufklappen_Grau"]',
    './div[@class="DottedLineClear"]',
    './div[@class="DottedLine"]',
    './div[@class="ModulLesermeinungenFooter"]',
    './/div[@class="ModulArtikelServices"]',
    './div[@style="padding:10px 0px; font-size:11px; line-height:16px; color:#7d7d7d"]',
    './div[@class="ModulVerlagsInfo"]',
    './div[@class="LinkBoxModulSmall"]',
    './/div[@id="MedRight"]',
    );

  for my $xpath ( @to_delete ) {
    for my $node ( $anke->findnodes( $xpath ) ) {
#      print "hit $xpath\n";
      $node->detach;   # delete element
    }
  }

  my $body;
  $body=$anke->as_HTML();

  my $scrubber = HTML::Scrubber->new( 
    deny => [ qw[ div noscript iframe ] ],
    default => 1,
  );
  $scrubber->rules(img => { "*" => 1 }, p => { "*" => 1 });
  $body = $scrubber->scrub($body);

  $body =~ s/&#132;/&bdquo;/g;
  $body =~ s/&#(147|148);/"/g;
  $body =~ s/&#39;/'/g;

  while ( $body =~ m/(&#x?\d+;)/g ) {
    warn "suspicious html entity $1\n";
  }

#  write_file("/tmp/out.html",$body);

  return($body);
}

sub test {
  my $str;

  unless ($ARGV[0] eq '' ) {
    $str = get($ARGV[0]);
  }
  else {
    my @lines = <>;
    $str = join('',@lines);
  }
  my $args = { content => $str };
  my $body = extract(0, $args);

}

test() unless (caller);
