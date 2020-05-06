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
echo Project Page: http://www.y-str.org/2015/07/y-str-kit.html
echo Script Developer: Felix Immanuel ^<i@fi.id.au^>

if [%1]==[] goto NOPARAM
echo.
echo Input VCF : %1
echo.

set CYGWIN=nodosfilewarning

bin\ubin\bgzip.exe %1
bin\ubin\tabix.exe %1.gz

echo Finding Y-STR Values ...
bin\ubin\ystrfinder.exe ref\ystr_info.txt %1.gz out\Y-STR_Report.html

echo.
out\Y-STR_Report.html

echo All Tasks Completed. Please find results in out subfolder.
echo Also check the logs/info in this window for errors (if any).
goto END
:NOPARAM
echo.
echo  Syntax:
echo     console_vcf ^<vcf-file^>
echo.
:END
pause