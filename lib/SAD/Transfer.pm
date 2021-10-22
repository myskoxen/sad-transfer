package SAD::Transfer;

use 5.006;
use strict;
use warnings;
use Traverse::Dir;

=head1 NAME

SAD::Transfer - The great new SAD::Transfer!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Provides basic functions to setup a transfer function, including virus scanning,
logging of meta data and more. Meant for easy configuration via a yaml file.

Basically you run.

    use SAD::Transfer;

    my $foo = SAD::Transfer->new();
    ...

=head1 EXPORT

verify

=head1 SUBROUTINES/METHODS

=head2 check_for_new_files



=cut

sub check_for_new_files {
    my $directory = shift;
    opendir( my $dh, "$basepath/$dir") or die "Error: Unable to open $dir forreading: $!";
    my @contents = grep(!/^.{1,2}$/, readdir($dh));
    close $dh;
    if( @contents ){
        # spawn a separate process to handle the uploaded files
        my $ret = spawn_watcher( $directory );
        if( $ret ){
            return 1;
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

=head2 spawn_watcher

=cut

sub spawn_watcher {
    my $directory_name = shift;
    my $blockfile = "$blockfiledir/$directory_name";
    my $pid = fork;
    if( defined $pid ){
        # Fork worked
        if( $pid ){
            # Parent
            return 1;
        } else {
            # Child
            await_upload_finish( $directory_name );
            run_transfer( $directory_name );
            return 0;
        }
    }
}

=head2 run_transfer

=cut

sub run_transfer {
    my $directory = shift;
    wait_to_finish_upload( $directory, $upload_directory );
    `mv $upload_path/$directory $working_path/$directory`;
    virus_scan_contents( $directory, $working_path );
    log_contents( $directory );
    transfer_contents( $directory );
}

=head2 wait_to_finish_upload

=cut

sub wait_to_finish_upload {
    my ($top_dir, $base_path) = @_;
    my $former_size = `du -bs $base_path/$top_dir` or die "Failed to run system command du to get size $!";
    my $timer = 6;
    my $breakout = 1;
    while $breakout {
        sleep $timer;
        # Check file size, if we grew files are still being uploaded,
        # then we patiently wait some more :)
        $current_size = `du -bs $base_path/$top_dir` or die "Failed to run system command du to get size $!";
        if( $current_size == $former_size ){
            # File is no longer being uploaded
            $breakout = 0;
        } else {
            # Potentially recalculate sleep period (i.e. $timer)
            if( $current_size >= $some_size ){
                $timer = df;
            }
            $former_size = $current_size
        }
    }
}

=head2 virus_scan_contents

=cut

sub virus_scan_contents {
    my ($top_dir, $base_path) = @_;
    traverse_dir( "$base_path/$top_dir", \&virus_scanner );
    
}

=head2 log_contents

=cut

sub log_contents {
    my ($top_dir, $base_path) = @_;
}

=head2 transfer_contents

=cut

sub transfer_contents {
    my ($top_dir, $base_path) = @_;
}


=head1 AUTHOR

Robert Lilja, C<< <robert at feychting.se> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-sad-transfer at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=SAD-Transfer>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SAD::Transfer


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=SAD-Transfer>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/SAD-Transfer>

=item * Search CPAN

L<https://metacpan.org/release/SAD-Transfer>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2021 by Robert Lilja.

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991


=cut

1; # End of SAD::Transfer
