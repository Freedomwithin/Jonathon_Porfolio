use strict;
use warnings;
use HTML::Template;
use Path::Tiny qw(path);
use YAML::Tiny;
use Data::Dumper;
use Cwd qw(getcwd);

# Get the current working directory
my $current_dir = getcwd();

# Load data from YAML
my $yaml = YAML::Tiny->read('data.yml');
if (!$yaml) {
    die "Failed to read YAML file: " . YAML::Tiny->errstr;
}

# The first element of $yaml contains the parsed data
my $data = $yaml->[0];
if (!$data || ref($data) ne 'HASH') {
    die "YAML content is not a hash reference";
}

my $name = $data->{name};
my $hero_description = $data->{hero_description};
my $bio = $data->{bio};
my $email = $data->{email};
my @projects = @{$data->{projects}};

# Template directory
my $template_dir = path($current_dir);
# Output directory
my $output_dir = path($current_dir, 'output');
$output_dir->mkpath;

# Function to generate HTML
sub generate_html {
    my ($template_file, $output_file, %params) = @_;  # Use a hash for params

    my $template_path = $template_dir->child($template_file);
    die "Template '$template_path' not found" unless $template_path->is_file;

    my $template = HTML::Template->new(filename => $template_path->stringify);
    $template->param(%params);  # Pass params as a hash

    my $output_path = $output_dir->child($output_file);
    $output_path->spew_utf8($template->output);
    print "Generated: $output_path\n";
}

# Generate HTML files
generate_html('index.html', 'index.html',
    name => $name, hero_description => $hero_description
);
generate_html('about.html', 'about.html', name => $name, bio => $bio);
generate_html('projects.html', 'projects.html', name => $name, projects => \@projects);
generate_html('contact.html', 'contact.html', name => $name, email => $email);

print "HTML generation complete.\n";