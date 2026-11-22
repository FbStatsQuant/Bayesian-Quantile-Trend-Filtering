@echo off
REM Rebuild main.pdf. Run from this folder (double-click, or `compile.bat` in a terminal).
REM Four passes: pdflatex, bibtex, pdflatex, pdflatex -- needed because the
REM bibliography and the table of contents each require a second resolution pass.
cd /d "%~dp0"
echo === pass 1/4: pdflatex ===
pdflatex -interaction=nonstopmode main.tex
echo === pass 2/4: bibtex ===
bibtex main
echo === pass 3/4: pdflatex ===
pdflatex -interaction=nonstopmode main.tex
echo === pass 4/4: pdflatex ===
pdflatex -interaction=nonstopmode main.tex
echo.
echo === errors, if any ===
findstr /B /C:"!" main.log
echo.
echo === undefined references and citations, if any ===
findstr /C:"LaTeX Warning: Reference" /C:"LaTeX Warning: Citation" main.log
echo.
echo Done. Open main.pdf
pause
