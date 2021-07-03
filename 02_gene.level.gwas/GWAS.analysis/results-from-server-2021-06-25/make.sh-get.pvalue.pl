#perl ../batch-process-mperm.pl ./name.list.1 >tmp1 &
@files=glob "name.list*";
print '#!/bin/bash
#SBATCH --time=16:00:00
#SBATCH --nodes=1   
#SBATCH --ntasks-per-node=6
#SBATCH --mem=80G';
print "\n";
for(@files){
	$n++;
	print "perl ../../batch-process-mperm.pl $_ >tmp$n &\n";
}
print "wait\n";
