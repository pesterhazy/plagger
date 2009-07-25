use HTML::Scrubber;
use LWP::Simple;

sub handle {
    my($self, $args) = @_;
    $args->{entry}->permalink =~ m!http://www.sueddeutsche.de!;
}

sub extract {
  my($self, $args) = @_;
  my $str = $args->{content};
  my $body;

  if ($str =~ m#<div class="artikelheader clr.*?(<div class="main content.*?)(?:<table class="bgf2f2f2 absatz">|<div class="artikelliste">|<div id="themenbox"|<div id="artikelfoot")#ms) {
    $body = $1;
  } elsif ($str =~ m#(<div class="main content.*?)(?:<table class="bgf2f2f2 absatz">|<div class="artikelliste">|<div id="themenbox"|<div id="artikelfoot")#ms) {
    $body = $1;
  }
  else {
    if (defined $args->{entry}) {
      print STDERR "WARNING: Did not match: " . $args->{entry}->permalink . "\n";
    } 
    else {
      print STDERR "WARNING: Did not match: unknown\n";
    }
    return;
  }

  $body =~ s#<!-- Stoerer //-->.*?<!-- END Stoerer //-->##ms;
  $body =~ s#<!-- performance media -->.*?<!-- //performance media -->##ms;
  $body =~ s#<span>\s*Anzeige\s*</span>##msi;
  $body =~ s#<p class="bannerAnzeige">ANZEIGE</p>##msi;
  $body =~ s#<span class="bannerAnzeige">ANZEIGE</span>##msi;

  my $scrubber = HTML::Scrubber->new( 
    deny => [ qw[ div noscript iframe ] ],
    default => 1,
  );
  $scrubber->rules(img => { "*" => 1 });
  $body = $scrubber->scrub($body);

  if ($str =~ m#<!-- paging -->#ms) {
    $body .= "<p>Mehr Seiten verfügbar...</p>\n";
  }
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
