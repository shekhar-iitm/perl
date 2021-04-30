use POSIX;
use Getopt::Long;

GetOptions(
   'rptFile=s' => \$rptFile,
   'pipe=s'    => \$pipe,
   'port=s'    => \$port,
   'cos=s'     => \$cos,
   'help'      => \$help,            
);

sub print_help {
    print <<EOM;

Usage: Parse_werrLog.pl -rptFile <sv.log.*>
EOM
    return 1;
};


if(defined($help)){ 
  print_help();
  exit;
}

#my $str2srch = 'pipe_'.$pipe.'_port_'.$port.'_schq_'.$cos.'_itm';
my $str2srch = 'pipe_'.$pipe.'_port_'.$port.'_cos_'.$cos;
my @arrWord;
my $nodeExp;
my $nodeAct;
my $nodeDelta;
my $absDelta;
my $rateDiff;
my $time;

my $rateTxt  = "OUTPUT/node".$cos."_exp_act.csv";
open(RPT, $rptFile) or die "Unable to open input report $rptFile.\n";
open(OUT, ">$rateTxt") or die "Unable to write to outfile $rateTxt\n";

#[1498668.873ns]...mu_qsch_env_0.mmu_qsch_checker_0: [BWCHK_L2]   MISMATCH byte_mode bw check on  pipe_0_port_10_schq_3_itm0  exp=15980680  act=16160886 
#[1946544.873ns]...mu_qsch_env_0.mmu_qsch_checker_0: [ BWCHK_L0]  MISMATCH byte_mode bw check on pipe_0_port_10_cos_2  exp=1640622  act=1671065 err_rate= 1.9
            print OUT "time, Exp, Act, absDelta, rateDiff, Delta \n";
while (my $line = <RPT>) {
    if ($line =~ /exp=/) {
        if ($line =~ /$str2srch/) {
            chomp $line;
            @arrWord = split (/(exp=|act=|err_rate=|diff=)/, $line);
            $nodeExp = $arrWord[2];
            $nodeAct = $arrWord[4];
            $rateDiff = $arrWord[6];
            $nodeDelta = $nodeExp - $nodeAct;
            $absDelta  = abs($nodeDelta);            
            $time = $arrWord[0];
            $time =~ s/ns\].*//;
            $time =~ s/\[//;
            print OUT "$time, $nodeExp, $nodeAct, $absDelta, $rateDiff, $nodeDelta, \n";
            #if ($line =~ /itm0/) {
            #   $itm0Exp = $arrWord[2];
            #   $itm0Act = $arrWord[4];
            #   $itm1Delta = $itm1Act-$itm1Exp;
            #} else {
            #   $itm1Exp = $arrWord[2];
            #   $itm1Act = $arrWord[4];
            #   $itm0Delta = $itm0Act-$itm0Exp;
            #   print OUT "$itm0Exp, $itm0Act, $itm0Delta, $itm1Exp, $itm1Act, $itm1Delta \n";
            #}
        }
    }

}
close $RPT;
close $OUT;
