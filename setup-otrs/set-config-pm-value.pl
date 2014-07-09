#!/usr/bin/perl -w

# sets Value in /opt/otrs/Kernel/Config.pm
# copied from OTRS Installer

use strict;
use warnings;

my $OTRS_HOME="/opt/otrs";

sub ReConfigure {
    my ( %Param ) = @_;

    # perl quote
    for my $Key ( keys %Param ) {
        if ( $Param{$Key} ) {
            $Param{$Key} =~ s/'/\\'/g;
        }
    }

    # read config file
    my $ConfigFile = "$OTRS_HOME/Kernel/Config.pm";
    open( my $In, '<', $ConfigFile )
        || return "Can't open $ConfigFile: $!";
    my $Config = '';
    while (<$In>) {
        if ( $_ =~ /^#/ ) {
            $Config .= $_;
        }
        else {
            my $NewConfig = $_;

            # replace config with %Param
            for my $Key ( keys %Param ) {
                if ( $Param{$Key} =~ /^[0-9]+$/ && $Param{$Key} !~ /^0/ ) {
                    $NewConfig
                        =~ s/(\$Self->{("|'|)$Key("|'|)} =.+?);/\$Self->{'$Key'} = $Param{$Key};/g;
                }
                else {
                    $NewConfig
                        =~ s/(\$Self->{("|'|)$Key("|'|)} =.+?');/\$Self->{'$Key'} = '$Param{$Key}';/g;
                }
            }
            $Config .= $NewConfig;
        }
    }
    close $In;

    # add new config settings
    for my $Key ( sort keys %Param ) {
        if ( $Config !~ /\$Self->{("|'|)$Key("|'|)} =.+?;/ ) {
            if ( $Param{$Key} =~ /^[0-9]+$/ && $Param{$Key} !~ /^0/ ) {
                $Config =~ s/\$DIBI\$/\$DIBI\$\n    \$Self->{'$Key'} = $Param{$Key};/g;
            }
            else {
                $Config =~ s/\$DIBI\$/\$DIBI\$\n    \$Self->{'$Key'} = '$Param{$Key}';/g;
            }
        }
    }

    # write new config file
    open( my $Out, '>', $ConfigFile )
        || return "Can't open $ConfigFile: $!";
    print $Out $Config;
    close $Out;

    return;
} 

sub usage_and_exit {
die ("Usage: $0 KEY1=VALUE1 [ KEY2=VALUE2 ...]\n
      For example: $0 CheckMXRecord=0 DatabasePw=HellFire");
}

&usage_and_exit() unless scalar @ARGV > 0;

my %Param = ();
for my $Arg (@ARGV){
   my ($Key,$Val) = split(/=/,$Arg,2);
   print "Key: '$Key', Val: '$Val'\n";
   $Param{$Key} = $Val;
}
my $Error = ReConfigure(%Param);
if ($Error){
   print STDERR "Error processing Config.pm: $Error\n";
   &usage_and_exit();
}

exit(0);


