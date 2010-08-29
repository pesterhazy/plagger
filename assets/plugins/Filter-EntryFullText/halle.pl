use HTML::Query 'Query';
use LWP::Simple;
use HTML::TreeBuilder::XPath;
use HTML::Selector::XPath 'selector_to_xpath';
use HTML::Scrubber;

sub css_query {
  my ($str, $selector) = @_;
  my $tree=HTML::TreeBuilder::XPath->new;
  $tree->parse($str);
  my $result=$tree->findnodes(selector_to_xpath($selector));
  return $result->[0]->as_HTML;
}

sub scrub {
  my ($body) = @_;
  my $scrubber = HTML::Scrubber->new( 
    deny => [ qw[ div noscript iframe ] ],
    default => 1,
  );
  $scrubber->rules(img => { "*" => 1 }, p => { "*" => 1 });
  $body = $scrubber->scrub($body);
  return $body;
}

sub handle {
    my($self, $args) = @_;

#    print $args->{entry}->permalink . "\n"; # for debugging

    $args->{entry}->permalink =~ m!http://.*\.faz\.net!;
#    $args->{entry}->permalink eq 'http://www.faz.net/s/RubDA5AEED6E6AB48F9A65EA41107C817DD/Doc~E860009E060A34688A7E7B774EA57AAB1~ATpl~Ecommon~Sspezial.html?rss_feuilleton';


sub extract {
  my($self, $args) = @_;
  my $str = $args->{content};

  my $element=css_query($str,"div.box3_new p");

  print scrub($element);
}
