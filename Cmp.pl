eval '(exit $?0)' &&
  eval 'exec perl -S $0 ${1+"$@"}' &&
  eval 'exec perl -S $0 $argv:q'
if 0;


use strict;
use warnings;
use IO::File;
use File::Basename qw(basename);
use Cwd;
use Getopt::Long;
use List::MoreUtils qw(uniq);
use Data::Dumper;

sub parse_rules {
  my $file = shift;

  &check_file($file);
  my $file_fh = IO::File->new("$file",'r');
  my (%ruleChecks, $tvfName, $loadName, $initName, $xform);
  while (<$file_fh>) {
    chomp(my $line = $_);
    if ( $line =~ /^\s*(LVS )?PERC\s+LOAD\s+(\S+)(\s+NAME\s+(\S+))?(\s+PATTERN \"\S+\")?(\s+XFORM (\S+))?(\s+INIT\s+(\S+))?\s+SELECT(\s+\(\s*(\S+.*?\S+)\s*\))? PARALLEL ORDER\s+\[\s*(.*)?\s*\](\s+SELECTTYPE\s+INFO\s+\S+.*\S+)?(\s+SELECTTYPE UNWAIVABLE\s+\S+.*\S+)?\s*$/i ) {
      $tvfName = $2;
      $loadName = $4;
      $xform = $7;
      $initName = $9;
      $initName = 'NO_INIT' if !defined($initName);
      $loadName = 'NO_LOAD_NAME' if !defined($loadName);
      $xform = uc($xform) if defined($xform);
      $xform = 'NO_XFORM' if !defined($xform);
      my $preExecRules = $11;
      my @preExecRules = split /\s+/, $preExecRules if defined($preExecRules);
      push @{$ruleChecks{$tvfName}{$loadName}{$xform}{$initName}}, \@preExecRules if @preExecRules;
      my @ruleChecks = split /\s*\]\s*\[\s*/, $12;
      my $groupNum = 0;
      foreach my $group (@ruleChecks) {
        $groupNum++;
        my @group = split /\s+/, $group;
        @group = grep !/^(\(|\))$/, @group;
        foreach (@group) {
          $_ =~ s/\((\S+)/$1/;
          $_ =~ s/(\S+)\)/$1/;
        }
        push @{$ruleChecks{$tvfName}{$loadName}{$xform}{$initName}}, \@group;
        #foreach my $ruleCheck (@group) {
          #$ruleChecks{$tvfName}{$loadName}{$xform}{$initName}{$ruleCheck} = $groupNum;
        #}
      }
    }
  }
  return \%ruleChecks;
}

sub parse_log {
  my $file = shift;

  &check_file($file);
  my $file_fh = IO::File->new("$file",'r');
  my ($tvfName, $loadName, $initName, $xform);
  my (%launch_line, %finish_line, %waiverLaunch_line, %wavierFinish_line);
  while (<$file_fh>) {
    chomp(my $line = $_);
    if ( $line =~ /^Executing PERC LOAD (\S+) (NAME (\S+) )?(XFORM (\S+) )?(INIT (\S+) )?\.\.\.\s*$/ ) {
      $tvfName = $1;
      $loadName = $3;
      $xform = $5;
      $initName = $7;
      $initName = 'NO_INIT' if !defined($initName);
      $loadName = 'NO_LOAD_NAME' if !defined($loadName);
      $xform = uc($xform) if defined($xform);
      $xform = 'NO_XFORM' if !defined($xform);
    } elsif ( $line =~ /^\s+Executing RuleCheck \"(\S+)\" on thread \d+ \.\.\.\s*$/ ) {
      $launch_line{$tvfName}{$loadName}{$xform}{$initName}{$1} = $.;
    } elsif ( $line =~ /^\s+RuleCheck \"(\S+)\" executed on thread \d+\.\s+CPU.*$/ ) {
      $finish_line{$tvfName}{$loadName}{$xform}{$initName}{$1} = $.;
    } elsif ( $line =~ /^Applying result WAIVERS for RuleCheck \"(\S+)\" on thread \d+ \.\.\.\s*$/ ) {
      $waiverLaunch_line{$tvfName}{$loadName}{$xform}{$initName}{$1} = $.;
    } elsif ( $line =~ /^WAIVERS applied for RuleCheck \"(\S+)\" on thread \d+\.\s+CPU.*$/ ) {
      $wavierFinish_line{$tvfName}{$loadName}{$xform}{$initName}{$1} = $.;
    }
  }

    return (\%launch_line, \%finish_line, \%waiverLaunch_line, \%wavierFinish_line);
}

sub check_file {
  my $file = shift;

  if ( ! -f $file ) {
    print "ERROR: $file does not exist\n";
	exit 1;
  } 
}

sub check_lines {
  my $ruleChecks = shift;
  my $launch_line = shift;
  my $finish_line = shift;
  my $waiverLaunch_line = shift;
  my $wavierFinish_line = shift;
  my $debug_on = shift;

  my (%order, %launch_line_local, %finish_line_local, %waiverLaunch_line_local, %wavierFinish_line_local, @groupNums);
  my @errors;
  foreach my $tvfName (keys %$ruleChecks) {
    foreach my $loadName (keys %{$$ruleChecks{$tvfName}}) {
      foreach my $xform (keys %{$$ruleChecks{$tvfName}{$loadName}}) {
        foreach my $initName (keys %{$$ruleChecks{$tvfName}{$loadName}{$xform}}) {
          my $groupNum = 1;
          my @flattened_ruleChecks;
          push @flattened_ruleChecks, @$_ for @{$$ruleChecks{$tvfName}{$loadName}{$xform}{$initName}};
          #print Dumper(\@flattened_ruleChecks);
          foreach my $group (@{$$ruleChecks{$tvfName}{$loadName}{$xform}{$initName}}) {
            foreach my $ruleCheck (@$group) {
              #print "DEBUG: $groupNum: $ruleCheck\n";
              #print "DEBUG: ${ruleCheck}\n";
              #print "DEBUG: @flattened_ruleChecks\n";
              @flattened_ruleChecks = grep !/^${ruleCheck}$/, @flattened_ruleChecks;
            }
            foreach my $ruleCheck (@$group) {
              my $preRule_launch = $$launch_line{$tvfName}{$loadName}{$xform}{$initName}{$ruleCheck};
              my $preRule_finish = $$finish_line{$tvfName}{$loadName}{$xform}{$initName}{$ruleCheck};
              my $preWaiver_launch = $$waiverLaunch_line{$tvfName}{$loadName}{$xform}{$initName}{$ruleCheck};
              my $preWaiver_finish = $$wavierFinish_line{$tvfName}{$loadName}{$xform}{$initName}{$ruleCheck};
              if ( !defined($preRule_launch) || !defined($preRule_finish) ) {
                print "DEBUG1: $tvfName: $loadName  $xform  $initName  $ruleCheck\n";
                push @errors, "either the launch or finish line do not exist for  $tvfName: $loadName  $xform  $initName  $ruleCheck\n";
              } else {
                push @errors, "The finished time is earlier than launch time for $ruleCheck.  See lines $preRule_launch and $preRule_finish\n" if $preRule_launch > $preRule_finish;
                push @errors, "The finished time is earlier than launch time for $ruleCheck waiver.  See lines $preWaiver_launch and $preWaiver_finish\n" if defined($preWaiver_launch) && defined($preWaiver_finish) && $preWaiver_launch > $preWaiver_finish;
                push @errors, "The waiver launch time is earlier than finish time for $ruleCheck waiver.  See lines $preWaiver_launch and $preRule_finish\n" if defined($preWaiver_launch) && $preWaiver_launch < $preRule_finish;
              }
              foreach my $postRuleCheck (@flattened_ruleChecks) {
                my $postRule_launch = $$launch_line{$tvfName}{$loadName}{$xform}{$initName}{$postRuleCheck};
                my $postRule_finish = $$finish_line{$tvfName}{$loadName}{$xform}{$initName}{$postRuleCheck};
                my $postWaiver_launch = $$waiverLaunch_line{$tvfName}{$loadName}{$xform}{$initName}{$postRuleCheck};
                my $postWaiver_finish = $$wavierFinish_line{$tvfName}{$loadName}{$xform}{$initName}{$postRuleCheck};
                if ( !defined($postRule_launch) || !defined($postRule_finish) ) {
                  print "DEBUG2: $tvfName: $loadName  $xform  $initName  $ruleCheck\n";
                  push @errors, "either the launch or finish line do not exist for  $tvfName: $loadName  $xform  $initName  $ruleCheck\n";
                } else {
                  push @errors, "The launch time for $ruleCheck should be earlier than that of $postRuleCheck\n" if $preRule_launch > $postRule_launch;
                  push @errors, "The finish time for $ruleCheck should be earlier than that of $postRuleCheck\n" if $preRule_finish > $postRule_launch;
                }
              }
            }
            print Dumper(\@flattened_ruleChecks) if defined($debug_on);
            $groupNum++;
          }
        }
      }
    }
  }
  return \@errors;
}

sub print_pass {
  print "**************\n";
  print "*   PASSED   *\n";
  print "**************\n";
}
sub print_fail {
  print "**************\n";
  print "*   FAILED   *\n";
  print "**************\n";
}
my ($log, $rules, $debug_on, $parse);
GetOptions ( "debug"    => \$debug_on,
			 "log=s"    => \$log,
			 "parse"    => \$parse,
			 "rules=s"    => \$rules
); 

$rules = "./rules" if ! defined($rules);
$log = "./qaout.log" if ! defined($log);
my $ruleChecks  = &parse_rules($rules);
if ( ! keys %$ruleChecks ) {
  &print_fail;
  print "No rules check were identified\n";
  exit 1;
}
my ($launch_line, $finish_line, $waiverLaunch_line, $wavierFinish_line) = &parse_log($log);

if ( defined($debug_on) ) {
  print "ruleChecks\n";
  print Dumper($ruleChecks);
  print "launch_line\n";
  print Dumper($launch_line);
  print "finish_line\n";
  print Dumper($finish_line);
  print "waiverLaunch_line\n";
  print Dumper($waiverLaunch_line);
  print "wavierFinish_line\n";
  print Dumper($wavierFinish_line);
}
if ( ! keys %$launch_line || ! keys %$finish_line ) {
  &print_fail;
  print "No ruleCheck is launched or executed\n";
  exit 1;
}

exit 0 if defined($parse);
my $errors = &check_lines($ruleChecks, $launch_line, $finish_line, $waiverLaunch_line, $wavierFinish_line, $debug_on);
if ( ! @$errors  ) {
  &print_pass;
  exit 0;
} else {
  &print_fail;
  foreach (@$errors) {
    print "$_";
  }
  exit 1;
}
