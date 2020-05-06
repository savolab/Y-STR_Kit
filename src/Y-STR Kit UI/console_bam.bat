@echo off
title Y-STR Kit 1.1

REM     The MIT License (MIT)
REM     Copyright © 2013-2015 Felix Immanuel
REM     http://www.y-str.org
REM     
REM     Permission is hereby granted, free of charge, to any person obtaining a copy
REM     of this software and associated documentation files (the Softwareù), to deal
REM     in the Software without restriction, including without limitation the rights
REM     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
REM     copies of the Software, and to permit persons to whom the Software is furnished
REM     to do so, subject to the following conditions: The above copyright notice and
REM     this permission notice shall be included in all copies or substantial portions
REM     of the Software. THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY
REM     KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
REM     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
REM     EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
REM     OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
REM     ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
REM     OTHER DEALINGS IN THE SOFTWARE.

echo.
echo *** Y-STR Kit 1.1 ***
echo.
echo Tools Used: SAMTools, picard, Cygwin, GATK, Java
echo Project Page: http://www.y-str.org/2015/07/y-str-kit.html
echo Script Developer: Felix Immanuel ^<i@fi.id.au^>
echo.

if [%1]==[] goto NOPARAM
echo.
echo Input BAM : %1
echo.

set CYGWIN=nodosfilewarning

echo Pre-execution Cleanup ...
IF EXIST bam_chrY.vcf DEL /Q /F bam_chrY.vcf
IF EXIST bam_chrY.vcf.gz.tbi DEL /Q /F bam_chrY.vcf.gz.tbi
IF EXIST bam_chrY.vcf.idx DEL /Q /F bam_chrY.vcf.idx
IF EXIST bam_complete_sorted.bam DEL /Q /F bam_complete_sorted.bam
IF EXIST bam_complete_sorted.bam.bai DEL /Q /F bam_complete_sorted.bam.bai
IF EXIST bam_sorted.bam DEL /Q /F bam_sorted.bam
IF EXIST bam_sorted.bam.bai DEL /Q /F bam_sorted.bam.bai
IF EXIST bam_sorted_realigned.bai DEL /Q /F bam_sorted_realigned.bai
IF EXIST bam_sorted_realigned.bam DEL /Q /F bam_sorted_realigned.bam
IF EXIST bam_sorted_realigned.bam.bai DEL /Q /F bam_sorted_realigned.bam.bai
IF EXIST bam_wh.bam DEL /Q /F bam_wh.bam
IF EXIST bam_wh_tmp.bam DEL /Q /F bam_wh_tmp.bam
IF EXIST chr DEL /Q /F chr
IF EXIST chrY.bam DEL /Q /F chrY.bam
IF EXIST header DEL /Q /F header
IF EXIST header01 DEL /Q /F header01
IF EXIST header02 DEL /Q /F header02
IF EXIST inchr.bam DEL /Q /F inchr.bam
IF EXIST inchr.sam DEL /Q /F inchr.sam
IF EXIST reads.bam DEL /Q /F reads.bam
IF EXIST tmp.sam DEL /Q /F tmp.sam


echo Sorting ...
bin\ubin\samtools.exe sort %1 bam_complete_sorted

echo.
echo Indexing the sorted BAM file ...
bin\ubin\samtools.exe index bam_complete_sorted.bam

echo Splitting and preparing Chr Y ...
bin\ubin\samtools.exe view -H bam_complete_sorted.bam|bin\ubin\cut -f2|bin\ubin\grep SN|bin\ubin\grep Y|bin\ubin\cut -d':' -f2|bin\ubin\head -1 > chr
for /F "tokens=1" %%C in (chr) do (
bin\ubin\samtools.exe view -b bam_complete_sorted.bam %%C > chrY.bam
)

echo Checking and fixing ...
IF EXIST inchr.bam DEL /Q /F  inchr.bam
copy chrY.bam inchr.bam > NUL

echo.
echo Preparing BAM ...
bin\ubin\samtools.exe view inchr.bam | bin\ubin\sed 's/\t/\tchr/2' > tmp.sam
bin\ubin\cat tmp.sam | bin\ubin\sed 's/\tchrchr/\tchr/' > inchr.sam

bin\ubin\samtools.exe view -bT ref\chrY.fa inchr.sam > reads.bam
bin\ubin\samtools.exe view -H inchr.bam|bin\ubin\grep -v SN > header01
bin\ubin\samtools.exe view -H reads.bam > header02
copy header01+header02 header /Y /B > NUL
bin\ubin\samtools.exe reheader header reads.bam > bam_wh_tmp.bam

echo Adding or Replace Read Group Header ...
bin\jre\bin\java.exe -Xmx2g -jar bin\picard\picard.jar AddOrReplaceReadGroups INPUT=bam_wh_tmp.bam OUTPUT=bam_wh.bam SORT_ORDER=coordinate RGID=rgid RGLB=rglib RGPL=illumina RGPU=rgpu RGSM=sample VALIDATION_STRINGENCY=SILENT

echo Sorting ...
bin\ubin\samtools.exe sort bam_wh.bam bam_sorted

echo.
echo Indexing the sorted BAM file ...
bin\ubin\samtools.exe index bam_sorted.bam

echo.
echo Realignment of the sorted and indexed BAM file ...
bin\jre\bin\java.exe -Xmx2g -jar bin\gatk\GenomeAnalysisTK.jar -T RealignerTargetCreator -R ref\chrY.fa -I bam_sorted.bam  -o bam.intervals
bin\jre\bin\java.exe -Xmx2g -jar bin\gatk\GenomeAnalysisTK.jar -T IndelRealigner -R ref\chrY.fa -I bam_sorted.bam -targetIntervals bam.intervals -o bam_sorted_realigned.bam
	
echo.
echo Indexing the realigned BAM file ...
bin\ubin\samtools.exe index bam_sorted_realigned.bam

echo.
echo Invoke the variant caller ...
bin\jre\bin\java.exe -Xmx2g -jar bin\gatk\GenomeAnalysisTK.jar -l INFO -R ref\chrY.fa -T UnifiedGenotyper -glm BOTH -I bam_sorted_realigned.bam -rf BadCigar -nct 2 -o bam_chrY.vcf --output_mode EMIT_ALL_CONFIDENT_SITES

bin\ubin\bgzip.exe bam_chrY.vcf
bin\ubin\tabix.exe bam_chrY.vcf.gz

echo Finding Y-STR Values ...
bin\ubin\ystrfinder.exe ref\ystr_info.txt bam_chrY.vcf.gz out\Y-STR_Report.html

REM -- final cleanup
MOVE bam_chrY.vcf.gz out >NUL

IF EXIST bam_chrY.vcf DEL /Q /F bam_chrY.vcf
IF EXIST bam_chrY.vcf.gz.tbi DEL /Q /F bam_chrY.vcf.gz.tbi
IF EXIST bam_chrY.vcf.idx DEL /Q /F bam_chrY.vcf.idx
IF EXIST bam_complete_sorted.bam DEL /Q /F bam_complete_sorted.bam
IF EXIST bam_complete_sorted.bam.bai DEL /Q /F bam_complete_sorted.bam.bai
IF EXIST bam_sorted.bam DEL /Q /F bam_sorted.bam
IF EXIST bam_sorted.bam.bai DEL /Q /F bam_sorted.bam.bai
IF EXIST bam_sorted_realigned.bai DEL /Q /F bam_sorted_realigned.bai
IF EXIST bam_sorted_realigned.bam DEL /Q /F bam_sorted_realigned.bam
IF EXIST bam_sorted_realigned.bam.bai DEL /Q /F bam_sorted_realigned.bam.bai
IF EXIST bam_wh.bam DEL /Q /F bam_wh.bam
IF EXIST bam_wh_tmp.bam DEL /Q /F bam_wh_tmp.bam
IF EXIST chr DEL /Q /F chr
IF EXIST chrY.bam DEL /Q /F chrY.bam
IF EXIST header DEL /Q /F header
IF EXIST header01 DEL /Q /F header01
IF EXIST header02 DEL /Q /F header02
IF EXIST inchr.bam DEL /Q /F inchr.bam
IF EXIST inchr.sam DEL /Q /F inchr.sam
IF EXIST reads.bam DEL /Q /F reads.bam
IF EXIST tmp.sam DEL /Q /F tmp.sam
IF EXIST bam.intervals DEL /Q /F bam.intervals

echo.
out\Y-STR_Report.html

echo All Tasks Completed. Please find results in out subfolder.
echo Also check the logs/info in this window for errors (if any).
goto END
:NOPARAM
echo.
echo  Syntax:
echo     console_bam ^<bam-file^>
echo.
:END
pause