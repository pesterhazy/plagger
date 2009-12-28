use HTML::Scrubber;
use LWP::Simple;
use HTML::TreeBuilder::XPath;

sub handle {
    my($self, $args) = @_;
    $args->{entry}->permalink =~ m!http://.*\.faz\.net!;
}

sub extract {
  my($self, $args) = @_;
  my $str = $args->{content};
  my $body;

  print("Link: " . $args->{entry}->permalink . "\n");

  my $tree= HTML::TreeBuilder::XPath->new;
  $tree->parse($str);

  my @to_delete = (
    '//div[@id="ArtikelServicesMenu"]',
    '//div[@class="BoxTool Aufklappen_Grau"]',
    '//div[@class="DottedLineClear"]',
    '//div[@class="DottedLine"]',
    '//div[@class="ModulLesermeinungenFooter"]',
    '//div[@class="ModulArtikelServices"]',
    '//div[@style="padding:10px 0px; font-size:11px; line-height:16px; color:#7d7d7d"]',
    '//div[@class="ModulVerlagsInfo"]',
    );

  for my $xpath ( @to_delete ) {
    print ("checking xpath $xpath...\n");
    for my $node ( $tree->findnodes( $xpath ) ) {
      print ("found node $node\n");
      $node->detach;   # delete element
    }
  }

  my $body;
  $body=$tree->findnodes_as_string('//div[@class="BlogPost"]');
  if ( !$body ) {
    $body=$tree->findnodes_as_string('//div[@class="Article"]');
    if ( !$body ) {
      $body=$tree->findnodes_as_string('//div[@id="MedContent"]');
      if ( !$body ) {
        die("No such div found");
      }
    }
  }

#  if ($str =~ m#<div class="artikelheader clr.*?(<div class="main content.*?)(?:<table class="bgf2f2f2 absatz">|<div class="artikelliste">|<div id="themenbox"|<div id="artikelfoot")#ms) {
#    $body = $1;
#  } elsif ($str =~ m#(<div class="main content.*?)(?:<table class="bgf2f2f2 absatz">|<div class="artikelliste">|<div id="themenbox"|<div id="artikelfoot")#ms) {
#    $body = $1;
#  }
#  elsif ($str =~ m#(<div id="contentcolumn" class="entry-content" role="main">.*?)(?:<table class="bgf2f2f2 absatz">|<div class="artikelliste">|<div id="themenbox"|<div id="artikelfoot")#ms) {
#    $body = $1;
#  }
#  else {
#    if (defined $args->{entry}) {
#      print STDERR "WARNING: Did not match: " . $args->{entry}->permalink . "\n";
#    } 
#    else {
#      print STDERR "WARNING: Did not match: unknown\n";
#    }
#    return;
#  }
#  $body =~ s#<span class="bannerAnzeige">ANZEIGE</span>##msi;

  my $scrubber = HTML::Scrubber->new( 
    deny => [ qw[ div noscript iframe ] ],
    default => 1,
  );
  $scrubber->rules(img => { "*" => 1 });
  $body = $scrubber->scrub($body);

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

  print $body;
}

test() unless (caller);
