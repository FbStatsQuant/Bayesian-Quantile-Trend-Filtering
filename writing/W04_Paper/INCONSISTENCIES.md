# W-04 inconsistencies (log for a later pass; do not fix during W-04)

Format: file:line — what. Append only.

- paper/sections/simulations.tex — after the restructure, the demoted headings "Varying smoothness" and "Smooth signal" are \paragraph, the same level as the existing \paragraph{Data}, \paragraph{Methods}, etc. Section 4 drafting should resolve the hierarchy.
- paper/sections/{discussion,data_application,appendix_*}.tex — "Section~\ref{sec:simulations|sec:scalability|sec:air_simulation}" now renders as a subsection number (e.g. "Section 4.1"). Check the wording.
